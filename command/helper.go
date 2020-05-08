package command

import (
	"io/ioutil"
	"net/http"
)

// ang counts the int32 value of all runes of string 's'
// and then mods it by 'm'. 'ang' stands for Arbitrary Number Generator.
func ang(s string, m int32) int32 {
	runes := []rune(s)
	var res int32

	for _, ele := range runes {
		res += ele
	}

	return res % m
}

// getJSON returns the response body from a json request.
func getJSON(uri string) ([]byte, error) {
	response, err := http.Get(uri)
	if err != nil {
		return []byte{}, err
	}
	data, err := ioutil.ReadAll(response.Body)

	return data, err
}
