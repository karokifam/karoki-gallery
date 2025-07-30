package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	// Change this to the path you want to scan
	basePath := ""
	fmt.Scanln(&basePath)
	outputFile := "assetspath.txt"

	// Create or truncate the output file
	file, err := os.Create(outputFile)
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer file.Close()

	// Walk through the basePath
	err = filepath.Walk(basePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Only consider directories (skip the root itself)
		if info.IsDir() && path != basePath {
			folderName := filepath.Base(path)
			line := fmt.Sprintf(" - assets/memory_items/%s/\n", folderName)
			_, writeErr := file.WriteString(line)
			if writeErr != nil {
				return writeErr
			}
		}
		return nil
	})

	if err != nil {
		fmt.Println("Error walking through path:", err)
	} else {
		fmt.Println("assetspath.txt generated successfully!")
	}
}
