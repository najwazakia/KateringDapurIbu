package main

import (
	"html/template"
	"log"
	"net/http"
)

// Fungsi pembantu untuk me-render template
func renderTemplate(w http.ResponseWriter, page string, data interface{}) {
	// Parse layout utama dan file halaman yang diminta
	tmpl, err := template.ParseFiles("templates/layout.html", "templates/"+page)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Eksekusi template layout yang di dalamnya sudah memanggil konten
	err = tmpl.ExecuteTemplate(w, "layout", data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func main() {
	// Routing untuk setiap halaman
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "dashboard.html", nil)
	})

	http.HandleFunc("/bahan-baku", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "bahan_baku.html", nil)
	})

	http.HandleFunc("/resep", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "resep.html", nil)
	})

	http.HandleFunc("/menu", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "menu.html", nil)
	})

	// Jalankan server
	log.Println("Server berjalan di http://localhost:8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("Gagal menjalankan server: ", err)
	}
}
