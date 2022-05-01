f0 = './entrance_img/entrance.txt'
f1 = './entrance_img/entrance_corredor_1_P.txt'
with open(f0, 'r') as file0:
    text0 = file0.read()
    with open(f1, 'r') as file1:
        text1 = file1.read()
        i = 0
        text0 = text0.split('\n')
        text1 = text1.split('\n')
        result = ''
        for i in range(len(text0)):
            result = result + text0[i] + text1[i] + '\n'
        previous = f'prologue: .word {(len(text0[0])//2)+(len(text1[0])//2)}, 240\n.byte ' 
#write to file
with open('./entrance_img/entrance.txt', 'w') as file:
    file.write(previous)
    file.write(result)