package handlers

import (
	"github.com/google/uuid"
	"github.com/nikkbh/users-rest-api/internal/dto"
	"github.com/nikkbh/users-rest-api/internal/models"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// @Summary Get all users
// @Description Retrieve list of users
// @Tags users
// @Accept json
// @Produce json
// @Success 200 {array} models.User
// @Router /users [get]
func ListUsers(c *fiber.Ctx) error {
	db := c.Locals("db").(*gorm.DB)
	var users []models.User
	if err := db.Find(&users).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(users)
}

// @Summary Create user
// @Description Create new user
// @Tags users
// @Accept json
// @Produce json
// @Param user body dto.CreateUserRequest true "User data"
// @Success 201 {object} models.User
// @Failure 409 {object} map[string]string "Conflict"
// @Router /users [post]
func CreateUser(c *fiber.Ctx) error {
	var input dto.CreateUserRequest
	if err := c.BodyParser(&input); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	db := c.Locals("db").(*gorm.DB)

	// Validate uniqueness - use models.User for DB query
	var existing models.User
	if err := db.Where("username = ?", input.Username).First(&existing).Error; err == nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "Username exists"})
	}
	if err := db.Where("email = ?", input.Email).First(&existing).Error; err == nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "Email exists"})
	}

	// Map DTO to User model (auto-generates ID, timestamps)
	newUser := models.User{
		Username: input.Username,
		Email:    input.Email,
	}

	// Create with User model - GORM handles defaults
	if err := db.Create(&newUser).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(newUser) // Return full User
}

// @Summary Get user by ID
// @Description Retrieve single user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 200 {object} models.User
// @Failure 404 {object} map[string]string "Not found"
// @Router /users/{id} [get]
func GetUser(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid ID"})
	}

	db := c.Locals("db").(*gorm.DB)
	var user models.User
	if err := db.First(&user, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(user)
}

// @Summary Update user
// @Description Update user by ID
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param user body dto.UpdateUserRequest true "Updated data"
// @Success 200 {object} models.User
// @Failure 404 {object} map[string]string "Not found"
// @Router /users/{id} [put]
func UpdateUser(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid ID"})
	}

	db := c.Locals("db").(*gorm.DB)
	var user models.User
	if err := db.First(&user, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
	}

	var input dto.UpdateUserRequest
	if err := c.BodyParser(&input); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	if input.Username != "" {
		var existing models.User
		if err := db.Where("username = ?", input.Username).First(&existing).Error; err == nil {
			return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "Username taken"})
		}
		user.Username = input.Username // Set on model
	}

	// Save triggers UpdatedAt automatically
	if err := db.Save(&user).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(user)
}

// @Summary Delete user
// @Description Delete user by ID
// @Tags users
// @Param id path string true "User ID"
// @Success 204 {object} nil
// @Failure 404 {object} map[string]string "Not found"
// @Router /users/{id} [delete]
func DeleteUser(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid ID"})
	}

	db := c.Locals("db").(*gorm.DB)
	if err := db.Delete(&models.User{}, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
	}
	return c.SendStatus(fiber.StatusNoContent)
}
