package search

// WikiList is used for grabbing relevant information from the Search/List
// response.
type WikiList struct {
	Items []item `json:"items"`
}

// WikiSimple is used for grabbing relevant information from the
// Articles/AsSimpleJson response.
//
// **VERY MISLEADING NAME!**
type WikiSimple struct {
	Sections []section `json:"sections"`
}

type section struct {
	Content []content `json:"content"`
}

type content struct {
	Text string `json:"text"`
}

type item struct {
	ID    int    `json:"id"`
	Title string `json:"title"`
	URL   string `json:"url"`
}
