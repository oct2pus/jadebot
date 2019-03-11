package search

// Booru contains all relevant information pulled from a mspabooru search.
type Booru struct {
	Posts []struct {
		FileURL string `xml:"file_url,attr"`
		Source  string `xml:"source,attr,omitempty"`
	} `xml:"post"`
}
