m = int(input("Masukan total Jam :"))
saldo = int(input("Total e money :"))

hari = m >=24
jam = m<24
jumlah_hari_tidak_bulat = (m % 24) != 0
total_harga = hari*((m//24 + 1*(jumlah_hari_tidak_bulat))*25000) + jam*(m*1000)

saldo_gacukup = saldo <= total_harga
isi_saldo = saldo_gacukup*(total_harga-saldo)
print(f"Tarif yg harus dibayar adalah :{total_harga}")
print(f"Harus mengisi saldo sebesar :{isi_saldo}")
