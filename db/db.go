package db

import (
	"database/sql"
	"fmt"
	"strings"
	"sync"

	// SQL Driver
	_ "github.com/mattn/go-sqlite3"
)

var (
	db  *sql.DB
	mux sync.Mutex
)

//
// Query values to be modified by function.
//

// lookQuery looks up a VALUE from table !A where GUILD_ID=?.
const lookQuery = `SELECT VALUE FROM !A WHERE GUILD_ID=?;`

// createQuery creates table !A with value VALUE as a TEXT.
const createQuery = `CREATE TABLE IF NOT EXISTS !A (
	GUILD_ID INTEGER NOT NULL PRIMARY KEY,
	VALUE TEXT,
	);`

// entryQuery inserts a row with values GUILD_ID and VALUE into table !A.
const insertQuery = `INSERT INTO !A (GUILD_ID, VALUE) VALUES (?,?);`

// updateQuery
const updateQuery = `UPDATE !A SET VALUE=!B WHERE GUILD_ID=? LIMIT 1;`

// InitDB initializes the sqlite db.
func InitDB() error {
	var err error
	db, err = sql.Open("sqlite3", "./jb.db")
	return err
}

// CreateTable creates tableName Table if it does not exist.
func CreateTable(tableName string) error {
	mux.Lock()
	defer mux.Unlock()
	query := strings.Replace(createQuery, "!A", tableName, 1)
	statement, err := db.Prepare(query)
	if err != nil {
		return err
	}
	defer statement.Close()
	_, err = statement.Exec()
	return err
}

// AddEntry adds a Row with Values guildID and entry to Table tableName.
func AddEntry(guildID int, tableName, entry string) error {
	mux.Lock()
	defer mux.Unlock()
	lookup, err := LookupEntry(guildID, tableName)
	if err != nil {
		query := strings.Replace(insertQuery, "!A", tableName, 1)
		statement, err := db.Prepare(query)
		if err != nil {
			return err
		}
		defer statement.Close()
		statement.Exec(guildID, entry)
		_, err = statement.Exec()
		return err
	} else if lookup != entry {
		err := UpdateEntry(guildID, tableName, entry)
		return err
	}
	return nil
}

// LookupEntry returns the value of a row with
// a matching guildID from Table tablename.
func LookupEntry(guildID int, tableName string) (string, error) {
	var out string
	query := strings.Replace(lookQuery, "!A", tableName, 1)
	statement, err := db.Prepare(query)
	if err != nil {
		return "", err
	}
	defer statement.Close()
	result, err := statement.Query(guildID)
	if err != nil {
		return "", err
	}
	defer result.Close()
	result.Scan(&out)
	if result.Next() {
		cols, _ := result.Columns()
		// Warning because this is not supposed to happen, and it'd need to be manually fixed.
		fmt.Printf("H3Y D1PSH1T TH3 R3SULT R3TURN3D MOR3 TH4N ON3 T4BL3.\n %v\n F1X TH1S: %v\n", cols, result.Err())
	}
	return out, result.Err()
}

// UpdateEntry updates a row entry.
func UpdateEntry(guildID int, tableName, entry string) error {
	mux.Lock()
	defer mux.Unlock()
	query := strings.Replace(updateQuery, "!A", tableName, 1)
	query = strings.Replace(query, "!B", entry, 1)
	statement, err := db.Prepare(query)
	if err != nil {
		return err
	}
	defer statement.Close()
	_, err = statement.Exec()
	if err != nil {
		return err
	}
	return err
}
