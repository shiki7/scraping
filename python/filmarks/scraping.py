import requests
from bs4 import BeautifulSoup
import re
import csv
import time


def scraping(userId):
    ratings = []
    for page in range(1, 100):
        urlName = "https://filmarks.com/users/" + \
            userId + "?page=" + str(page) + "& view = rich"
        url = requests.get(urlName)
        soup = BeautifulSoup(url.content, "html.parser")

        elements = soup.find_all(class_="c-content-card__left")
        if not elements:
            break
        for element in elements:
            title = element.find(class_="c-content-card__title").find("a").text
            rating = element.find(class_="c-rating__score").text
            ratings.append([title, rating])

        # 負荷影響を考えて念の為にスリープを入れる
        time.sleep(1)

    return ratings


def sorted_ratings(ratings):
    return sorted(ratings, key=lambda x: x[1], reverse=True)


def write_csv(ratings):
    with open('./movie_rating.csv', 'w') as file:
        writer = csv.writer(file)
        for i in range(len(ratings)):
            writer.writerow(ratings[i])


def main():
    userId = input()
    ratings = scraping(userId)
    ratings = sorted_ratings(ratings)
    write_csv(ratings)


main()
