import { Delete, Edit } from '@mui/icons-material'
import {
  Alert,
  CircularProgress,
  IconButton,
  Paper,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow
} from '@mui/material'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { formatDistanceToNow } from 'date-fns'
import { Link } from 'react-router-dom'
import { usersApi } from '../api/users'
import type { User } from '../types/api'

export default function UsersList() {
  const queryClient = useQueryClient()
  
  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: usersApi.list
  })

  const deleteMutation = useMutation({
    mutationFn: usersApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    }
  })

  if (isLoading) return <CircularProgress sx={{ display: 'block', mx: 'auto', mt: 8 }} />
  if (error) return <Alert severity="error" sx={{ mt: 4 }}>Error loading users</Alert>

  return (
    <TableContainer component={Paper} sx={{ mt: 2 }}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>ID</TableCell>
            <TableCell>Username</TableCell>
            <TableCell>Email</TableCell>
            <TableCell>Created</TableCell>
            <TableCell>Actions</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {users?.map((user: User) => (
            <TableRow key={user.id}>
              <TableCell>{user.id.slice(0, 8)}...</TableCell>
              <TableCell>{user.username}</TableCell>
              <TableCell>{user.email}</TableCell>
              <TableCell>{formatDistanceToNow(new Date(user.created_at), { addSuffix: true })}</TableCell>
              <TableCell>
                <IconButton component={Link} to={`/edit/${user.id}`} size="small">
                  <Edit />
                </IconButton>
                <IconButton 
                  onClick={() => deleteMutation.mutate(user.id)}
                  disabled={deleteMutation.isPending}
                  size="small"
                >
                  <Delete />
                </IconButton>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  )
}
