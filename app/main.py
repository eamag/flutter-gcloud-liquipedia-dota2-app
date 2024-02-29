from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager
from aiolimiter import AsyncLimiter
import aiohttp
from app.notif import notify
import firebase_admin
from app.liquid import upcoming
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
import firebase_admin
from firebase_admin import credentials
from pathlib import Path

cred_path = "d2batchest-firebase-adminsdk.json"
if Path(cred_path).exists():
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
else:
    firebase_admin.initialize_app()

LIQUIPEDIA_API_URL = "https://liquipedia.net/dota2/api.php"

rate_limit = AsyncLimiter(1, 2)


class Cache:
    def __init__(self) -> None:
        self.all_teams = None
        self.last_update = datetime.now()
        self.upcoming_matches = []
        self.sent_notif = {}


cache = Cache()


def notify_every():
    cache.sent_notif = notify(cache.upcoming_matches, cache.sent_notif)


@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler()
    scheduler.add_job(notify_every, "interval", minutes=20)
    scheduler.start()
    yield
    scheduler.shutdown()


app = FastAPI(lifespan=lifespan)


async def make_request(url, params):
    headers = {
        "User-Agent": "d2bat/1.0 (http://www.example.com/; email@example.com)",
        "Accept-Encoding": "gzip",
    }
    async with rate_limit:
        async with aiohttp.ClientSession() as session:
            async with session.get(url, params=params, headers=headers) as response:
                response.raise_for_status()
                return await response.json()


async def get_all_dota2_teams():
    all_teams = {}
    try:
        gcmcontinue = None
        while True:
            params = {
                "action": "query",
                "format": "json",
                "prop": "info",
                "generator": "categorymembers",
                "gcmtitle": "Category:Teams",
                "gcmlimit": "500",
            }
            if gcmcontinue:
                params["gcmcontinue"] = gcmcontinue
            response_data = await make_request(LIQUIPEDIA_API_URL, params)
            query_data = response_data.get("query", {})
            team_data = query_data.get("pages", [])
            all_teams.update(team_data)
            # Check if there are more results
            continue_data = response_data.get("continue", {})
            gcmcontinue = continue_data.get("gcmcontinue")
            if not gcmcontinue:
                break

        return all_teams
    except aiohttp.ClientError as e:
        raise HTTPException(
            status_code=500, detail=f"Error accessing Liquipedia API: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")


@app.get("/upcoming_matches")
async def get_upcoming_matches():
    if (len(cache.upcoming_matches) == 0) or (
        datetime.now() - cache.last_update
    ).seconds > 60 * 2:
        cache.upcoming_matches = await upcoming()
        cache.last_update = datetime.now()
    return cache.upcoming_matches


@app.get("/all_teams")
async def get_dota2_teams():
    try:
        if not cache.all_teams:
            cache.all_teams = await get_all_dota2_teams()
        return {k: v["title"] for k, v in cache.all_teams.items()}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
