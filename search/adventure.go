package search

import (
	"strconv"
)

const (
	// PROLOGUE is the key for Prologue in Adventures.
	PROLOGUE = 0
	// MEAT is the key for Meat in Adventures.
	MEAT = 1
	// CANDY is the key for Candy in Adventures.
	CANDY = 2
	// HS is the key for Homestuck in Adventures.
	HS = 3
	// PS is the key for Problem Sleuth in Adventures.
	PS = 4
	// BQ is the key for Bard Quest in Adventures.
	BQ = 5
	// JB is the key for Jailbreak in Adventures.
	JB = 6
	// SBAHJ is the key for Sweet Bro and Hella Jeff in Adventures.
	SBAHJ = 7
)

// adventure represents an MSPaintAdventure!
// unexported because an adventure shouldn't be created on the fly.
type adventure struct {
	URL    string
	Name   string
	Start  int
	Finish int
}

// Adventures is all MSPaintAdventures.
// 0. is Prologue
// 1. is Meat
// 2. is Candy
// 3. is Homestuck
// 4. is Problem Sleuth
// 5. is Bard Quest
// 6. is Jailbreak
// 7. is Sweet Bro and Hella Jeff
var Adventures = []adventure{
	adventure{URL: "https://www.homestuck.com/epilogues/prologue/",
		Name:   "the prologue",
		Start:  0,
		Finish: 3},
	adventure{URL: "https://www.homestuck.com/epilogues/meat/",
		Name:   "meat",
		Start:  1,
		Finish: 44},
	adventure{URL: "https://www.homestuck.com/epilogues/candy/",
		Name:   "candy",
		Start:  1,
		Finish: 41},
	adventure{URL: "https://www.homestuck.com/story/",
		Name:   "homestuck",
		Start:  1,
		Finish: 8130},
	adventure{URL: "https://www.homestuck.com/problem-slueth/",
		Name:   "problem slueth",
		Start:  1,
		Finish: 1674},
	adventure{URL: "https://www.homestuck.com/bard-quest/",
		Name:   "bard quest",
		Start:  1,
		Finish: 47},
	adventure{URL: "https://www.homestuck.com/jailbreak/",
		Name:   "jailbreak",
		Start:  1,
		Finish: 134},
	adventure{URL: "https://www.homestuck.com/sweet-bro-and-hella-jeff/",
		Name:   "sbahj",
		Start:  1,
		Finish: 54},
}

// GetPage returns the url for a page in the adventure.
func (a adventure) GetPage(page int) string {
	if between(page, a.Start, a.Finish) {
		return a.URL + strconv.Itoa(page)
	}
	return "sorry but " + a.Name + " only has " +
		strconv.Itoa(a.Finish) + " pages. :("
}

// Get returns the URL for the first page of an adventure.
func (a adventure) Get() string {
	return a.URL
}

// random returns a random number between a.Start and a.Finish (inclusive).
// unused, currently.
/* func (a adventure) random() int {
	rand.Seed(time.Now().Unix())
	if a.Start == 0 {
		return rand.Intn(a.Finish + 1)
	}
	return rand.Intn(a.Finish) + a.Start
} */

// between returns if an int is between two numbers; inclusive range.
func between(desired, start, finish int) bool {
	if desired >= start && desired <= finish {
		return true
	}
	return false
}
