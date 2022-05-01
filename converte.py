# open ./assets/prologue - Copia.txt
import time

# time start
start_time = time.time()
with open('./assets/prologue - Copia.txt', 'r') as arquivo:
    # write into a new file
    
    texto = arquivo.read()
    t = texto.split(',')
    i = j = 0
    saida = ''
    for item in t:
        num = item
        if j == 0:
            #num = '0x'+item[11:13]+item[9:12]+item[7:9]
            num = '0x' + item[7:]
        # else:
        #     #print(item)
        #     num = '0x'+item[9:11]+item[7:9]+item[5:7]
        #print(num)
        #print(num) str(int(num,16)//32)

        saida = saida + str(-int(num,16)//32) + ', '
        i += 1
        if i == 1295:
            saida = saida + '\n'
            i = 0

    with open('./assets/prologue_new.txt', 'w') as arquivo_novo:
        arquivo_novo.write(saida)
# time end
end_time = time.time()
print('Tempo de execução: %s segundos' % (end_time - start_time))