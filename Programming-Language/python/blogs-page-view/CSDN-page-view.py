import requests
import time

from bs4 import BeautifulSoup
i=1

while True:
    print(f"第{i}轮")
    file=open('url.txt', 'r',encoding='utf-8',errors='ignore')
    while True:
        url=file.readline().rstrip()

        header={"user-agent":"Mozilla/5.0"}

        try:
            data=requests.get(url=url,headers=header)
        except ValueError:
            break
        else:
            if(data.status_code == 200):
                print(f"访问{url}成功")
            else:
                print(f"访问{url}失败")
            time.sleep(2)
    file.close()
    time.sleep(8)
    i+=1