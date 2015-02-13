package main

import (
	"crypto/md5"
	"database/sql"
	"fmt"
	"image"
	_ "image/jpeg"
	"log"
	"mime"
	"os"
	"path/filepath"

	"github.com/agorf/goexif/exif"
	_ "github.com/mattn/go-sqlite3"
)

type Photo struct {
	Aperture      sql.NullFloat64
	Camera        sql.NullString
	ExposureComp  sql.NullInt64
	ExposureTime  sql.NullFloat64
	Flash         sql.NullString
	FocalLength   sql.NullFloat64
	FocalLength35 sql.NullInt64
	Folder        string
	Height        int
	ISO           sql.NullInt64
	Identifier    string
	Lat           sql.NullFloat64
	Lens          sql.NullString
	Lng           sql.NullFloat64
	Path          string
	Size          int64
	Taken         sql.NullString
	Width         int
}

var (
	db                                                             *sql.DB
	selectSetStmt, selectPhotoStmt, insertSetStmt, insertPhotoStmt *sql.Stmt
)

func decodePhotoExif(photo *Photo, x *exif.Exif) {
	taken, err := x.DateTime()
	if err == nil {
		photo.Taken.String = taken.UTC().Format("2006-01-02 15:04:05")
		photo.Taken.Valid = true
	}

	lat, lng, err := x.LatLong()
	if err == nil {
		photo.Lat.Float64 = lat
		photo.Lat.Valid = true
		photo.Lng.Float64 = lng
		photo.Lng.Valid = true
	}

	orientTag, err := x.Get(exif.Orientation)
	if err == nil {
		switch orientTag.String() {
		case "5", "6", "7", "8": // rotated
			photo.Width, photo.Height = photo.Height, photo.Width // swap
		}
	}

	camMakeTag, err := x.Get(exif.Make)
	if err == nil {
		photo.Camera.String, _ = camMakeTag.StringVal()
		photo.Camera.Valid = true
	}

	camModelTag, err := x.Get(exif.Model)
	if err == nil {
		cameraModel, _ := camModelTag.StringVal()

		if photo.Camera.Valid {
			photo.Camera.String = fmt.Sprintf("%s %s", photo.Camera.String, cameraModel)
		} else {
			photo.Camera.String = cameraModel
			photo.Camera.Valid = true
		}
	}

	lensMakeTag, err := x.Get(exif.LensMake)
	if err == nil {
		photo.Lens.String, _ = lensMakeTag.StringVal()
		photo.Lens.Valid = true
	}

	lensModelTag, err := x.Get(exif.LensModel)
	if err == nil {
		lensModel, _ := lensModelTag.StringVal()

		if photo.Lens.Valid {
			photo.Lens.String = fmt.Sprintf("%s %s", photo.Lens.String, lensModel)
		} else {
			photo.Lens.String = lensModel
			photo.Lens.Valid = true
		}
	}

	focalLenTag, err := x.Get(exif.FocalLength)
	if err == nil {
		numer, denom, _ := focalLenTag.Rat2(0)
		photo.FocalLength.Float64 = float64(numer) / float64(denom)
		photo.FocalLength.Valid = true
	}

	focalLen35Tag, err := x.Get(exif.FocalLengthIn35mmFilm)
	if err == nil {
		photo.FocalLength35.Int64, _ = focalLen35Tag.Int64(0)
		photo.FocalLength35.Valid = true
	}

	apertureTag, err := x.Get(exif.FNumber)
	if err == nil {
		numer, denom, _ := apertureTag.Rat2(0)
		photo.Aperture.Float64 = float64(numer) / float64(denom)
		photo.Aperture.Valid = true
	}

	expTimeTag, err := x.Get(exif.ExposureTime)
	if err == nil {
		numer, denom, _ := expTimeTag.Rat2(0)
		photo.ExposureTime.Float64 = float64(numer) / float64(denom)
		photo.ExposureTime.Valid = true
	}

	isoTag, err := x.Get(exif.ISOSpeedRatings)
	if err == nil {
		photo.ISO.Int64, _ = isoTag.Int64(0)
		photo.ISO.Valid = true
	}

	expBiasTag, err := x.Get(exif.ExposureBiasValue)
	if err == nil {
		photo.ExposureComp.Int64, _ = expBiasTag.Int64(0)
		photo.ExposureComp.Valid = true
	}

	flash, err := x.Flash()
	if err == nil {
		photo.Flash.String = flash
		photo.Flash.Valid = true
	}
}

func decodePhoto(path string) (*Photo, error) {
	var photo Photo

	photo.Path = path
	photo.Folder = filepath.Base(filepath.Dir(path))
	photo.Identifier = fmt.Sprintf("%x", md5.Sum([]byte(path)))

	f, err := os.Open(path)
	if err != nil {
		return &photo, err
	}
	defer f.Close()

	fi, err := f.Stat()
	if err != nil {
		return &photo, err
	}
	photo.Size = fi.Size()

	img, _, err := image.DecodeConfig(f)
	if err != nil {
		return &photo, err
	}
	photo.Width, photo.Height = img.Width, img.Height

	f.Seek(0, 0) // rewind

	x, err := exif.Decode(f)
	if err == nil { // EXIF data exists
		decodePhotoExif(&photo, x)
	}

	return &photo, nil
}

func storePhoto(photo *Photo) error {
	var setId, photoId int64

	row := selectSetStmt.QueryRow(photo.Folder)
	err := row.Scan(&setId)

	if err == sql.ErrNoRows { // set does not exist
		result, err := insertSetStmt.Exec(photo.Folder) // create it
		if err != nil {
			return err
		}

		setId, err = result.LastInsertId()
		if err != nil {
			return err
		}
	}

	row = selectPhotoStmt.QueryRow(photo.Path)
	err = row.Scan(&photoId)

	if err == sql.ErrNoRows { // photo does not exist
		result, err := insertPhotoStmt.Exec(photo.Aperture, photo.Camera,
			photo.ExposureComp, photo.ExposureTime, photo.Flash, photo.FocalLength,
			photo.FocalLength35, photo.Height, photo.Identifier, photo.ISO, photo.Lat,
			photo.Lens, photo.Lng, photo.Path, setId, photo.Size, photo.Taken,
			photo.Width) // create it
		if err != nil {
			return err
		}

		photoId, err = result.LastInsertId()
		if err != nil {
			return err
		}

		fmt.Fprintf(os.Stderr, "photos id=%d path=%s\n", photoId, photo.Path)
	}

	return nil
}

func walk(path string, info os.FileInfo, err error) error {
	if info.IsDir() {
		return nil
	}

	if mime.TypeByExtension(filepath.Ext(path)) != "image/jpeg" {
		return nil
	}

	photo, err := decodePhoto(path)
	if err != nil {
		return err
	}

	storePhoto(photo)

	return nil
}

func updatePhotoSiblings() error {
	var prevId, prevSetId int

	tx, err := db.Begin()
	if err != nil {
		return err
	}

	updatePrevPhotoStmt, err := tx.Prepare(`
	UPDATE photos SET prev_photo_id = ? WHERE id = ?
	`)
	if err != nil {
		return err
	}
	defer updatePrevPhotoStmt.Close()

	updateNextPhotoStmt, err := tx.Prepare(`
	UPDATE photos SET next_photo_id = ? WHERE id = ?
	`)
	if err != nil {
		return err
	}
	defer updateNextPhotoStmt.Close()

	rows, err := tx.Query(`
	SELECT id, set_id FROM photos ORDER BY set_id, taken_at
	`)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var id, setId int
		rows.Scan(&id, &setId)

		if setId == prevSetId && prevId > 0 {
			updatePrevPhotoStmt.Exec(prevId, id)
			fmt.Fprintf(os.Stderr, "photos id=%d prev_photo_id=%d\n", id, prevId)
			updateNextPhotoStmt.Exec(id, prevId)
			fmt.Fprintf(os.Stderr, "photos id=%d next_photo_id=%d\n", prevId, id)
		}

		prevId = id
		prevSetId = setId
	}

	err = rows.Err()
	if err != nil {
		return err
	}

	err = tx.Commit()
	if err != nil {
		return err
	}

	return nil
}

func updateSets() error {
	tx, err := db.Begin()
	if err != nil {
		return err
	}

	photosCountStmt, err := tx.Prepare(`
	SELECT COUNT(*) FROM photos WHERE set_id = ?
	`)
	if err != nil {
		return err
	}
	defer photosCountStmt.Close()

	updateSetStmt, err := tx.Prepare(`
	UPDATE sets
	SET photos_count = ?, taken_at = ?, thumb_photo_id = ?
	WHERE id = ?
	`)
	if err != nil {
		return err
	}
	defer updateSetStmt.Close()

	rows, err := tx.Query(`
	SELECT id, set_id, MIN(taken_at) FROM photos GROUP BY set_id
	`)
	if err != nil {
		return err
	}
	defer rows.Close()

	for rows.Next() {
		var id, setId, photosCount int
		var taken sql.NullString

		rows.Scan(&id, &setId, &taken)

		row := photosCountStmt.QueryRow(setId)
		row.Scan(&photosCount)

		updateSetStmt.Exec(photosCount, taken, id, setId)
		fmt.Fprintf(os.Stderr, "sets id=%d photos_count=%d taken=\"%s\" thumb_photo_id=%d\n", setId, photosCount, taken, id)
	}

	err = rows.Err()
	if err != nil {
		return err
	}

	err = tx.Commit()
	if err != nil {
		return err
	}

	return nil
}

func main() {
	var err error

	if len(os.Args) == 1 {
		fmt.Fprintf(os.Stderr, "usage: %v path [path...]\n", os.Args[0])
		return
	}

	db, err = sql.Open("sqlite3", "thyme.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	selectSetStmt, err = db.Prepare("SELECT id FROM sets WHERE name = ?")
	if err != nil {
		log.Fatal(err)
	}
	defer selectSetStmt.Close()

	selectPhotoStmt, err = db.Prepare("SELECT id FROM photos WHERE path = ?")
	if err != nil {
		log.Fatal(err)
	}
	defer selectPhotoStmt.Close()

	insertSetStmt, err = db.Prepare("INSERT INTO sets (name) VALUES (?)")
	if err != nil {
		log.Fatal(err)
	}
	defer insertSetStmt.Close()

	insertPhotoStmt, err = db.Prepare(`
  INSERT INTO photos (
	aperture, camera, exposure_comp, exposure_time, flash, focal_length,
	focal_length_35, height, identifier, iso, lat, lens, lng, path, set_id, size,
	taken_at, width
  )
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `)
	if err != nil {
		log.Fatal(err)
	}
	defer insertPhotoStmt.Close()

	for i := 1; i < len(os.Args); i++ {
		filepath.Walk(os.Args[i], walk)
	}

	updatePhotoSiblings()
	updateSets()
}
