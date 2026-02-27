import { AppBar, Button, Container, Toolbar, Typography } from "@mui/material";
import { Route, Routes, useNavigate } from "react-router-dom";
import UsersList from "./components/UsersList";
import UserForm from "./components/UserForm";
import { Add } from "@mui/icons-material";

function App() {
  const navigate = useNavigate();

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <AppBar position="static" sx={{ mb: 4 }}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            <span>User Management POC</span>
          </Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => navigate("/create")}
            sx={{ ml: 2, backgroundColor: "grey" }}
          >
            Add User
          </Button>
        </Toolbar>
      </AppBar>
      <Routes>
        <Route path="/" element={<UsersList />} />
        <Route path="/edit/:id" element={<UserForm />} />
        <Route path="/create" element={<UserForm />} />
      </Routes>
    </Container>
  );
}

export default App;
