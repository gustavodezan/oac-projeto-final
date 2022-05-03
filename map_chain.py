f0 = './s_alucard_down/alucard_down.txt'
f1 = './s_alucard_down/alucard_down10.s'
print('[+] Map chain:')
print('[+] f0:', f0)
print('[+] f1:', f1)
with open(f0, 'r') as file0:
    text0 = file0.read().splitlines()
    with open(f1, 'r') as file1:
        text1 = file1.read().splitlines()
        i = 0
        result = ''
        for i in range(len(text0)):
            result = result + text0[i] + text1[i] + '\n'
        previous = f'prologue: .word {(len(text0[0])//2)+(len(text1[0])//2)}, 240\n.byte ' 
#write to file
with open('./s_alucard_down/alucard_down.txt', 'w') as file:
    #file.write(previous)
    file.write(result)