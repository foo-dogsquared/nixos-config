#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3

# This script is used for generating a JSON object from a Newpipe database to
# be used for multimedia archive task (i.e.,
# `config.tasks.multimedia-archive`).

import argparse
import sys
import sqlite3
import json
import re
import shutil
import tempfile
from pathlib import Path


def kebab_case(string):
    string = string.lower()
    string = re.sub(r"\s+", "-", string)
    string = re.sub("[^a-zA-Z0-9-]", "", string)
    string = re.sub("-+", "-", string)
    string = re.sub("^-|-$", "", string)
    return string


def extract_categories_from_db(db_file, categories):
    with sqlite3.connect(db_file) as db:
        db.row_factory = sqlite3.Row
        query = """
            SELECT subscriptions.name AS name, subscriptions.url AS url, feed_group.name AS tag
            FROM subscriptions
            INNER JOIN feed_group_subscription_join AS subs_join
            INNER JOIN feed_group
            ON subs_join.subscription_id = subscriptions.uid AND feed_group.uid = subs_join.group_id
            ORDER BY name COLLATE NOCASE;
        """

        data = {
            kebab_case(category): {"subscriptions": [], "extraArgs": []}
            for category in categories
        }

        for row in db.execute(query):
            category = row["tag"]
            if category in categories:
                data[kebab_case(category)]["subscriptions"].append(
                    {"url": row["url"], "name": row["name"]}
                )

        return data


def list_categories(db_file):
    with sqlite3.connect(db_file) as db:
        query = """
            SELECT name FROM feed_group ORDER BY name;
        """
        data = []
        for row in db.execute(query):
            data.append(row[0])
        return data


def extract_db(newpipe_archive):
    tmpdir = tempfile.mkdtemp(suffix="convert-newpipe-db")

    shutil.unpack_archive(newpipe_archive, tmpdir)
    return Path(tmpdir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "newpipe_db",
        metavar="NEWPIPE_DB",
        help="Newpipe database file (as a zip file) exported straight from the app.",
    )
    parser.add_argument(
        "categories",
        metavar="CATEGORIES",
        nargs="*",
        help="A list of categories to be extracted. If absent, it will extract with all categories.",
    )
    parser.add_argument(
        "--list-categories",
        "-l",
        action="store_true",
        help="List all categories from the database.",
    )
    parser.add_argument(
        "--output",
        "-o",
        action="store",
        metavar="FILE",
        help="If present, store the output in the given file",
    )

    args = parser.parse_args()
    newpipe_archive = args.newpipe_db
    tmpdir = extract_db(newpipe_archive)
    db_file = tmpdir / "newpipe.db"

    if args.list_categories:
        for category in list_categories(db_file):
            print(category)
    else:
        categories = []
        if not sys.stdin.isatty():
            for line in sys.stdin:
                categories.append(line.strip())

        if len(args.categories) > 0:
            categories = args.categories
        elif len(categories) == 0:
            categories = list_categories(db_file)

        data = extract_categories_from_db(db_file, categories)

        output_file = args.output
        if output_file:
            with open(output_file, mode="w", encoding="UTF-8") as file:
                json.dump(data, file, sort_keys=True, indent=2, ensure_ascii=False)
        else:
            print(json.dumps(data, sort_keys=True, indent=2, ensure_ascii=False))

    shutil.rmtree(tmpdir)

# vi:ft=python:ts=4
