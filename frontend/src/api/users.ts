import axios from 'axios'
import type { User, CreateUserRequest, UpdateUserRequest } from '../types/api'

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1',
})

export const usersApi = {
    list: (): Promise<User[]> => api.get('/users').then(res => res.data),
    get: (id: string): Promise<User> => api.get(`/users/${id}`).then(res => res.data),
    create: (data: CreateUserRequest): Promise<User> => api.post('/users', data).then(res => res.data),
    update: (id: string, data: UpdateUserRequest): Promise<User> => api.put(`/users/${id}`, data).then(res => res.data),
    delete: (id: string): Promise<void> => api.delete(`/users/${id}`)
}
