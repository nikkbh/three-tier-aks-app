package dto

type CreateUserRequest struct {
	Username string `json:"username" gorm:"-" validate:"required,min=3"` // gorm:"-" ignores DB
	Email    string `json:"email" gorm:"-" validate:"required,email"`
}

type UpdateUserRequest struct {
	Username string `json:"username" gorm:"-" validate:"omitempty,min=3"`
}
