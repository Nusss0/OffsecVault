anggaran = int(input("Masukan nilai anggaran : "))
subsidi = input("Apakah subsidi(y/n)? : ")
nunggak = int(input("Lama nunggak : "))

kwh = 0
bool_subsidi = False;
if subsidi=='y' :
    bool_subsidi = True;

if (nunggak > 30) :
    anggaran -= 100000
elif (nunggak >0):
    anggaran -= 25000

harga_atas = (1-0.3*bool_subsidi)*1800
harga_tengah = (1-0.3*bool_subsidi)*1400
harga_bawah  = (1-0.3*bool_subsidi)*1000
batas_bawah = 100*harga_bawah
batas_tengah = 200*harga_tengah

if (anggaran - batas_bawah) > 0 :
    kwh += 100
    anggaran -= batas_bawah
else :
    kwh += anggaran//harga_bawah
    anggaran = 0

if (anggaran - batas_tengah) > 0 :
    kwh += 200
    anggaran -= batas_tengah
else :
    kwh += anggaran//harga_tengah
    anggaran = 0

if (anggaran > 0) :
    kwh += anggaran//harga_atas
    anggaran = 0

print(f"kwh total {kwh}")
