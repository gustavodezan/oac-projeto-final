f0 = './s_black_screen_stage_2/entrance_pedra_top_col.s'
f1 = './s_black_screen_stage_2/black_screen_half.s'
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
with open('./s_black_screen_stage_2/entrance_pedra_top_col.s', 'w') as file:
    #file.write(previous)
    file.write(result)