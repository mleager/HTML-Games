#!/bin/bash

# Define the content of the HTML file with CSS styling
html_content='<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Choose a Game</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            text-align: center;
            margin: 0;
            padding: 0;
        }
        
        h1 {
            color: #333;
        }

        ul {
            list-style: none;
            padding: 0;
        }

        li {
            margin: 10px 0;
            font-size: 18px;
        }

        a {
            text-decoration: none;
            color: #007BFF;
        }

        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1>Choose a Game:</h1>
    <ul>
        <li><a href="https://www.mark-dns.de/2048">2048</a></li>
        <li><a href="https://www.mark-dns.de/floppybird">Floppybird</a></li>
        <li><a href="https://www.mark-dns.de/pong">Pong</a></li>
        <li><a href="https://www.mark-dns.de/snake">Snake</a></li>
    </ul>
</body>
</html>'

# Specify the file path for index.html
file_path="/var/www/html/index.html"

# Create the index.html file
echo "$html_content" > "$file_path"

# Notify the user that the file has been created
echo "index.html has been created at $file_path"
