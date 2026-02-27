import {
    Button,
    CircularProgress,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    TextField,
} from "@mui/material";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import React, { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { usersApi } from "../api/users";
import type { CreateUserRequest, UpdateUserRequest } from "../types/api";

export default function UserForm() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const isEdit = !!id;
  const { data: user, isLoading } = useQuery({
    queryKey: ["user", id],
    queryFn: () => usersApi.get(id!),
    enabled: isEdit,
  });
  const [formData, setFormData] = useState<
    CreateUserRequest | UpdateUserRequest
  >(
    user
      ? { username: user.username, email: user.email }
      : { username: "", email: "" },
  );
  const [errors, setErrors] = useState<{ username?: string; email?: string }>(
    {},
  );



  const createMutation = useMutation({
    mutationFn: usersApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      navigate("/");
    },
  });

  const updateMutation = useMutation({
    mutationFn: (data: UpdateUserRequest) => usersApi.update(id!, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
      navigate("/");
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: { username?: string; email?: string } = {};

    if (!formData.username || formData.username.length < 3)
      newErrors.username = "Min 3 chars";
    if (!formData.email || !/\S+@\S+\.\S+/.test(formData.email))
      newErrors.email = "Valid email required";

    if (Object.keys(newErrors).length) {
      setErrors(newErrors);
      return;
    }

    if (isEdit) {
      updateMutation.mutate(formData as UpdateUserRequest);
    } else {
      createMutation.mutate(formData as CreateUserRequest);
    }
  };

  const loading =
    isLoading || createMutation.isPending || updateMutation.isPending;

  return (
    <Dialog open={true} onClose={() => navigate("/")} maxWidth="sm" fullWidth>
      <DialogTitle>{isEdit ? "Edit User" : "Create User"}</DialogTitle>
      <form onSubmit={handleSubmit}>
        <DialogContent>
          {isLoading ? (
            <CircularProgress sx={{ display: "block", mx: "auto" }} />
          ) : (
            <>
              <TextField
                fullWidth
                margin="dense"
                label="Username"
                value={formData.username}
                onChange={(e) =>
                  setFormData({ ...formData, username: e.target.value })
                }
                error={!!errors.username}
                helperText={errors.username}
              />
              <TextField
                fullWidth
                margin="dense"
                label="Email"
                type="email"
                value={formData.email}
                onChange={(e) =>
                  setFormData({ ...formData, email: e.target.value })
                }
                error={!!errors.email}
                helperText={errors.email}
              />
            </>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => navigate("/")}>Cancel</Button>
          <Button type="submit" disabled={loading} variant="contained">
            {loading ? (
              <CircularProgress size={20} />
            ) : isEdit ? (
              "Update"
            ) : (
              "Create"
            )}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}
