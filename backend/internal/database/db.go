package database

import (
	"fmt"
	"log"

	"github.com/nikkbh/users-rest-api/internal/config"
	"github.com/nikkbh/users-rest-api/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Connect(cfg *config.Config) *gorm.DB {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Enable uuid-ossp extension
	err = db.Exec(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`).Error
	if err != nil {
		log.Fatal("Failed to enable uuid-ossp extension:", err)
	}

	// Auto-migrate
	err = db.AutoMigrate(&models.User{})
	if err != nil {
		log.Fatal("Migration failed:", err)
	}

	return db
}
