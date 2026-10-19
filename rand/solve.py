a = int(input("Masukan nilai A : "))
b = int(input("Masukan nilai B : "))
c = int(input("masukan nilai C : "))

# Kemungkinannya tu hanya 6, ABC ACB BAC BCA CAB CBA
#jdi kita susun dlu
digit_a =10
digit_b =10
digit_c =10

if(a>=10) :
    digit_a=100
if(b>=10) :
    digit_b=100
if(c>=10) :
    digit_c=100

abc = (a*digit_b+b)*digit_c + c
acb = (a*digit_c + c)*digit_b + b
bac = (b*digit_a + a)*digit_c + c
bca = (b*digit_c + c)*digit_a + a
cab = (c*digit_a + a)*digit_b + b
cba = (c*digit_b + b)*digit_a + a
print(abc,acb,bca,bac,cba,cab)
#tinggal cari mana yg max aja done
max = abc #asumsi awal dlu
if(acb > max) :
    max = acb
if(bac > max) :
    max = bac
if(bca > max) :
    max = bca
if(cab > max) :
    max = cab
if(cba > max) :
    max = cba

print(max)
