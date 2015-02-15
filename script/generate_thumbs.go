package main

import (
	"crypto/md5"
	"database/sql"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"sync"

	_ "github.com/mattn/go-sqlite3"
)

const (
	thumbsDir      = "public/thumbs"
	bigThumbSize   = "1000"
	smallThumbSize = "200"
	workers        = 4 // min: 1
)

func generateSmallThumb(photoPath, identifier string) (thumbPath string, err error) {
	thumbPath = path.Join(thumbsDir, fmt.Sprintf("%s_small.jpg", identifier))

	absThumbPath, err := filepath.Abs(thumbPath)
	if err != nil {
		return
	}

	if _, err = os.Stat(thumbPath); os.IsNotExist(err) { // file does not exist
		err = exec.Command(
			"vipsthumbnail", photoPath,
			"--rotate",
			"--size", smallThumbSize,
			"--crop",
			"--interpolator", "bicubic",
			"--output", absThumbPath+"[Q=97,no_subsample,strip]").Run()
	}

	return
}

func generateBigThumb(photoPath, identifier string) (thumbPath string, err error) {
	thumbPath = path.Join(thumbsDir, fmt.Sprintf("%s_big.jpg", identifier))

	absThumbPath, err := filepath.Abs(thumbPath)
	if err != nil {
		return
	}

	if _, err = os.Stat(thumbPath); os.IsNotExist(err) { // file does not exist
		err = exec.Command(
			"vipsthumbnail", photoPath,
			"--rotate",
			"--size", bigThumbSize,
			"--interpolator", "bicubic",
			"--output", absThumbPath+"[Q=97,no_subsample,strip]").Run()
	}

	return
}

func generateThumbsImpl(photoPath string) (err error) {
	identifier := fmt.Sprintf("%x", md5.Sum([]byte(photoPath)))

	bigThumbPath, err := generateBigThumb(photoPath, identifier)
	if err != nil { // error
		return
	}

	fmt.Println(bigThumbPath)

	smallThumbPath, err := generateSmallThumb(bigThumbPath, identifier)
	if err == nil { // success
		fmt.Println(smallThumbPath)
	}

	return
}

func generateThumbs(ch chan string, wg *sync.WaitGroup) {
	defer wg.Done()

	for photoPath := range ch {
		generateThumbsImpl(photoPath)
	}
}

func main() {
	if workers < 1 {
		log.Fatal("number of workers must be at least 1")
	}

	db, err := sql.Open("sqlite3", "thyme.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query(`
	SELECT path FROM photos
	JOIN sets ON photos.set_id = sets.id
	ORDER BY sets.taken_at DESC, photos.taken_at ASC
	`)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	if err := os.MkdirAll(thumbsDir, os.ModeDir|0755); err != nil {
		log.Fatal(err)
	}

	ch := make(chan string)
	wg := sync.WaitGroup{}

	for i := 0; i < workers; i++ {
		wg.Add(1)
		go generateThumbs(ch, &wg)
	}

	for rows.Next() {
		var photoPath string
		rows.Scan(&photoPath)
		ch <- photoPath
	}

	close(ch)
	wg.Wait()

	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
}
