package search

// Dog contains the returned value from a dog.ceo api call
type Dog struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}
