n = int(input("Masukkan sebuah bilangan : "))

digit_1 = n%10
digit_10 = (n//10)%10
digit_100 = (n//100)%10
digit_1000 = n//1000

jlh_semua_digit = digit_1 + digit_10 + digit_100 + digit_1000

if (jlh_semua_digit % digit_1 == 0) & (jlh_semua_digit % digit_10 ==0) & (jlh_semua_digit % digit_100 ==0) & (jlh_semua_digit % digit_1000 ==0) :
    print('Bravo')
else :
    print('Ga bravo')
