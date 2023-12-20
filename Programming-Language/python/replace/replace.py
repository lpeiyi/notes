import re  
  
# 打开要修改的文件  
with open('52.txt', 'r',encoding='utf-8') as file:  
    # 读取文件内容  
    lines = file.readlines()  
  
# 添加行首和行尾的**，只对以数字加顿号开头的行进行替换  
new_lines = []  
pattern = re.compile(r'^\d+\、')  
for line in lines:  
    if pattern.match(line):  
        new_lines.append('**' + line.strip() + '**')  
    else:  
        new_lines.append(line.strip())  
  
# 写入修改后的内容到新的文件  
with open('520.txt', 'w',encoding='utf-8') as file:  
    for line in new_lines:  
        file.write(line + '\n')