# Sistem Perencanaan Produksi Katering Dapur Ibu

Aplikasi web untuk membantu Katering Dapur Ibu merencanakan produksi, menghitung kebutuhan bahan baku, mencatat persediaan, dan menghitung HPP menu.

## Status

Repository ini masih dalam tahap penyiapan fondasi. Lokasi entry point dan file modul sudah disiapkan, ERD awal disetujui, serta schema dan seed MySQL telah disiapkan. Aplikasi belum memiliki fungsi `main` atau fitur yang dapat dijalankan. ERD ada di `db/erd.md`.

## Ruang lingkup

- Mengelola bahan baku, satuan, dan harga.
- Mengelola resep bertingkat, komponen masakan, dan menu.
- Mencatat pelanggan dan pesanan berdasarkan tanggal acara.
- Menghitung kebutuhan bahan dan daftar belanja per tanggal produksi.
- Mencatat pembelian, stok, dan pemakaian bahan.
- Menghitung HPP per porsi dan menyajikan laporan pemakaian bahan.

## Teknologi dan keputusan awal

- Backend dan rendering halaman: Go `net/http` dan HTML templates.
- Database: MySQL Server 8.0.46.
- Database client: MySQL Workbench.
- UI: HTML templates dengan Bootstrap.
- Versi Go minimum mengikuti direktif `go` di `go.mod`.


## Struktur repository

```text
cmd/web/main.go                  Entry point dan wiring (Chesta)
db/erd.md                        ERD awal yang disetujui
db/schema.sql                    Definisi database (Chesta)
db/seed.sql                      Data awal database (Chesta)
internal/
  config/config.go               Konfigurasi aplikasi (Chesta)
  handler/
    dashboard.go
    bahan_baku.go
    resep.go
    menu.go
    pesanan.go
    perencanaan.go
    persediaan.go
    produksi.go
    laporan.go
    render.go                    Renderer bersama
  middleware/logging.go
  model/
    errors.go                    Error aplikasi bersama
    bahan_baku.go
    resep.go
    menu.go
    pesanan.go
    perencanaan.go
    persediaan.go
    produksi.go
    laporan.go
  repository/
    bahan_baku.go
    resep.go
    menu.go
    pesanan.go
    persediaan.go
    produksi.go
    laporan.go
  service/
    bahan_baku.go
    resep.go
    menu.go
    pesanan.go
    perencanaan.go
    persediaan.go
    produksi.go
    laporan.go
templates/
  layouts/base.html
  partials/navbar.html
  partials/sidebar.html
  partials/footer.html
  pages/
    dashboard/index.html          Jia
    bahan_baku/list.html          Jia
    bahan_baku/form.html          Jia
    resep/list.html               Jia
    resep/form.html               Jia
    menu/list.html                Jia
    menu/form.html                Jia
    pesanan/list.html             Wawa
    pesanan/form.html             Wawa
    pesanan/detail.html           Wawa
    perencanaan/index.html        Wawa
    persediaan/list.html          Wawa
    persediaan/pembelian_form.html Wawa
    produksi/index.html           Wawa
    laporan/pemakaian.html        Wawa
    laporan/hpp.html              Wawa
static/
  css/
  js/
  images/
```

File Go yang berisi deklarasi `package` saja dan file HTML berisi komentar placeholder hanya menunjukkan lokasi kode; belum ada fitur atau kontrak template yang ditetapkan. Nama file menunjukkan modul bisnis, sedangkan folder menunjukkan lapisan. Perencanaan ditempatkan di service karena perhitungan kebutuhan mengorkestrasi data resep, pesanan, dan stok, bukan menjadi sumber query database tersendiri. Nama template dan data yang dirender harus disepakati dengan handler sebelum implementasi UI.

Alur request mengikuti pola:

```text
HTTP request -> Handler -> Service -> Repository -> MySQL
```

Model digunakan lintas lapisan. Handler menangani HTTP dan template, service menangani aturan bisnis, dan repository menjadi tempat query SQL. `cmd/web/main.go` nantinya menyambungkan dependency antarlapisan.

## Pembagian kerja tim

Pembagian berikut menetapkan pemilik awal file agar pekerjaan tidak saling tumpang tindih. File kerangka saat ini belum berisi implementasi fitur.

| Anggota | Bagian | File/folder yang dikerjakan | Tanggung jawab |
|---|---|---|---|
| **Chesta (lead)** | Database dan integrasi | `db/schema.sql`, `db/seed.sql`, `cmd/web/main.go`, `internal/config/config.go` | Menyepakati ERD dan model bersama; mengatur konfigurasi dan koneksi database; menyambungkan handler, service, dan repository; mengintegrasikan PR serta debugging lintas modul. |
| **Ihsan (backend)** | Bahan baku, resep, menu, HPP | `internal/model/{bahan_baku,resep,menu}.go`; `internal/repository/{bahan_baku,resep,menu}.go`; `internal/service/{bahan_baku,resep,menu}.go`; `internal/handler/{bahan_baku,resep,menu}.go` | Mengimplementasikan pengelolaan bahan baku, satuan dan konversi, harga, resep bertingkat, komponen/menu, serta perhitungan HPP. |
| **Gibran (backend)** | Pesanan dan operasional produksi | `internal/model/{pesanan,perencanaan,persediaan,produksi,laporan}.go`; `internal/repository/{pesanan,persediaan,produksi,laporan}.go`; `internal/service/{pesanan,perencanaan,persediaan,produksi,laporan}.go`; `internal/handler/{pesanan,perencanaan,persediaan,produksi,laporan}.go` | Mengimplementasikan pesanan dan aturan perubahan dua hari sebelum acara; menghitung kebutuhan serta daftar belanja; mencatat pembelian, stok dan pemakaian produksi; menyajikan laporan pemakaian. Kerjakan bertahap: pesanan → perencanaan → stok/produksi → laporan. |
| **Jia (frontend)** | Dashboard dan data menu | `templates/pages/dashboard/`, `templates/pages/bahan_baku/`, `templates/pages/resep/`, `templates/pages/menu/`; aset tampilan di `static/` bila diperlukan | Membuat tampilan dashboard, bahan baku, resep dan menu menggunakan Go HTML templates. Koordinasikan nama template dan data yang dibutuhkan dengan Ihsan/Chesta. |
| **Wawa (frontend)** | Pesanan dan operasional | `templates/pages/pesanan/`, `templates/pages/perencanaan/`, `templates/pages/persediaan/`, `templates/pages/produksi/`, `templates/pages/laporan/`; aset tampilan di `static/` bila diperlukan | Membuat tampilan pesanan, perencanaan, persediaan, produksi dan laporan menggunakan Go HTML templates. Koordinasikan nama template dan data yang dibutuhkan dengan Gibran/Chesta. |

**File bersama—koordinasikan sebelum mengubahnya:**

- `internal/model/errors.go`: error aplikasi yang dapat dipakai lintas modul.
- `internal/handler/render.go`: renderer template bersama.
- `internal/middleware/logging.go`: middleware HTTP.
- `cmd/web/main.go`, `internal/config/config.go`, `db/schema.sql`, dan `db/seed.sql`: milik Chesta sebagai penanggung jawab integrasi/database.
- `templates/layouts/` dan `templates/partials/`: komponen UI bersama; Jia dan Wawa sepakati perubahan layout, navigasi, dan footer.

**Aturan integrasi:** backend memberi tahu frontend nama route, nama file template, dan field data yang akan dirender sebelum kedua sisi mengimplementasikan satu halaman. Frontend tidak menjalankan query SQL. Jangan mengubah file milik anggota lain tanpa koordinasi, dan gabungkan pekerjaan melalui Pull Request.

## Persiapan lokal Windows

1. Install Git dan Go dengan versi yang memenuhi `go.mod`.
2. Clone repository:

   ```powershell
   git clone https://github.com/najwazakia/KateringDapurIbu.git
   Set-Location KateringDapurIbu
   ```

3. Buat file konfigurasi lokal dari contoh:

   ```powershell
   Copy-Item .env.example .env
   ```

4. Pastikan MySQL Server lokal berjalan dan catat port serta akun database lokal. Target skema saat ini MySQL Server 8.0.46. MySQL Workbench adalah client untuk mengelola koneksi; Workbench sendiri bukan database server.
5. Atur `DB_DSN` di `.env` agar cocok dengan MySQL Server lokal. Jangan pernah mengisi credential asli di `.env.example` atau mengirim `.env` ke Git.
6. Di MySQL Workbench, buka dan jalankan `db/schema.sql`, lalu jalankan `db/seed.sql`. Schema membuat database `katering_dapur_ibu` dan 16 tabel; seed mengisi satuan standar. File schema adalah bootstrap awal, bukan migrasi untuk memperbarui database yang sudah berisi data.
7. Verifikasi hasil di SQL Editor:

   ```sql
   SELECT VERSION();

   SELECT COUNT(*) AS table_count
   FROM information_schema.tables
   WHERE table_schema = 'katering_dapur_ibu'
     AND table_type = 'BASE TABLE';

   SELECT symbol, name, dimension
   FROM katering_dapur_ibu.units
   ORDER BY id;
   ```

   Hasil yang diharapkan: versi server `8.0.46`, `table_count` bernilai `16`, dan enam satuan standar (`g`, `kg`, `ml`, `l`, `pcs`, `portion`).

Jika XAMPP masih terpasang, jangan jalankan service MariaDB bersamaan dengan MySQL pada port yang sama. Pastikan koneksi Workbench benar-benar menuju MySQL Server yang dipilih. Jangan jalankan file SQL pada server yang berisi database lain yang tidak terkait proyek. Aplikasi belum dapat dijalankan sampai entry point dan koneksi database dibuat.

## Menjalankan dan menguji

Perintah menjalankan aplikasi akan didokumentasikan setelah `cmd/web/main.go` dan konfigurasi database tersedia. Setelah itu, validasi dasar Go dapat dilakukan dengan:

```powershell
go test ./...
```

## Kolaborasi

Kerjakan perubahan melalui branch fitur dan Pull Request ke `main`. Hindari bekerja langsung pada branch `main`. Sebelum mulai mengerjakan modul, sinkronkan branch dengan `main` dan sepakati file atau kontrak yang akan disentuh bersama.

Standar branch, commit, pembagian modul, dan checklist Pull Request akan dilengkapi pada tahap penyiapan kolaborasi tim.
