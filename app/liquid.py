import requests
from bs4 import BeautifulSoup

# URL of the webpage
url = "https://liquipedia.net/dota2/Liquipedia:Upcoming_and_ongoing_matches"

headers = {
    "User-Agent": "d2bat/1.0 (http://www.example.com/; email@example.com)",
    "Accept-Encoding": "gzip",
}


def remove_duplicate_matches(matches):
    """Removes duplicate matches from a list of matches.

    Args:
        matches: A list of dictionaries, where each dictionary represents a match.

    Returns:
        A list of dictionaries, where each dictionary represents a unique match.
    """

    seen_matches = set()
    unique_matches = []

    for match in matches:
        # Create a unique key for the match based on its essential attributes
        match_key = (match["team1"], match["team2"], match["datetime"])

        if match_key not in seen_matches:
            seen_matches.add(match_key)
            unique_matches.append(match)

    return unique_matches


# Send a GET request to the URL
async def upcoming():
    response = requests.get(url, headers=headers)
    matches = []
    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Get the HTML content
        html = response.text

        soup = BeautifulSoup(html, "html.parser")

        # Find all tables with class "wikitable"
        tables = soup.find_all("table", class_="wikitable")

        # Iterate through each table and extract team1, team2, and datetime
        for table in tables:
            team1_element = table.find("td", class_="team-left")
            team1 = team1_element.text.strip()
            team1_name = (
                team1_element.find("a")["title"] if team1_element.find("a") else None
            )
            team1_href = (
                team1_element.find("a")["href"] if team1_element.find("a") else None
            )

            # Extract team2
            team2_element = table.find("td", class_="team-right")
            team2 = team2_element.text.strip()
            team2_name = (
                team2_element.find("a")["title"] if team2_element.find("a") else None
            )
            team2_href = (
                team2_element.find("a")["href"] if team2_element.find("a") else None
            )

            # Extract datetime using data-timestamp attribute
            datetime_value = (
                table.find("span", {"data-timestamp": True})["data-timestamp"]
                if table.find("span", {"data-timestamp": True})
                else None
            )

            # Extract image URLs
            team1_image_url = (
                table.select_one(".team-left img").get("src")
                if table.select_one(".team-left img")
                else None
            )
            team2_image_url = (
                table.select_one(".team-right img").get("src")
                if table.select_one(".team-right img")
                else None
            )
            matches.append(
                {
                    "team1": team1,
                    "team1_name": team1_name,
                    "team1_href": team1_href,
                    "team2": team2,
                    "team2_name": team2_name,
                    "team2_href": team2_href,
                    "datetime": datetime_value,
                    "team1_image_url": team1_image_url,
                    "team2_image_url": team2_image_url,
                }
            )
        return remove_duplicate_matches(matches)
    else:
        print(f"Failed to retrieve the webpage. Status code: {response.status_code}")
