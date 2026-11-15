```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="com.foodloop.dao.UserDAO" %>
<%@ page import="com.foodloop.model.User" %>
<%@ page import="java.util.List" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?unauthorized=1");
        return;
    }

    String role = (String) session.getAttribute("userRole");

    if (role == null || !"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required.");
        return;
    }

    String adminName = (String) session.getAttribute("userName");

    List<User> users = null;
    String loadError = null;

    try {
        UserDAO userDAO = new UserDAO();
        users = userDAO.findAllUsers();
    } catch (Exception e) {
        application.log("Unable to load users for admin screen.", e);
        loadError = "Unable to load users from the database. "
                  + "Check the server log and database connection.";
    }

    String deleted = request.getParameter("deleted");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users | FoodLoop</title>
    <link rel="stylesheet" href="../css/admin.css">

    <style>
        .user-action-cell {
            white-space: nowrap;
        }

        .user-delete-button {
            background: #b83232;
            color: #ffffff;
            border: none;
            border-radius: 6px;
            padding: 8px 13px;
            font: inherit;
            cursor: pointer;
        }

        .user-delete-button:hover {
            background: #922626;
        }

        .user-protected-label {
            color: #647067;
            font-size: 0.9rem;
        }

        .user-action-message {
            margin: 0 0 16px;
            padding: 12px 16px;
            border-radius: 8px;
        }

        .user-action-success {
            background: #e8f5e9;
            color: #216b35;
        }

        .user-action-error {
            background: #fff0ed;
            color: #9b2c20;
        }
    </style>
</head>
<body>

<div class="admin-layout">

    <aside class="sidebar">
        <a href="dashboard.jsp" class="brand">Food<span>Loop</span></a>
        <p class="sidebar-label">Administration</p>

        <button type="button" id="mobileMenuButton"
                class="mobile-menu-button"
                aria-expanded="false"
                aria-controls="sidebarNav">☰ Menu</button>

        <nav class="sidebar-nav open" id="sidebarNav">
            <a href="dashboard.jsp">▦ Dashboard</a>
            <a class="active" href="manage-users.jsp">♙ Manage Users</a>
            <a href="manage-donations.jsp">♧ Manage Donations</a>
            <a href="manage-requests.jsp">☷ Manage Requests</a>
            <a href="statistics.jsp">▤ Statistics</a>
            <a class="logout-link"
               href="<%= request.getContextPath() %>/logout">↪ Logout</a>
        </nav>
    </aside>

    <main class="main-content">

        <header class="topbar">
            <div>
                <h1 class="page-title">Manage Users</h1>
                <p class="page-subtitle">
                    Review registered FoodLoop accounts.
                </p>
            </div>

            <div class="admin-profile">
                <div class="profile-icon">A</div>
                <div>
                    <p class="profile-name"><%= escapeHtml(adminName) %></p>
                    <p class="profile-role">Administrator</p>
                </div>
            </div>
        </header>

        <% if (loadError != null) { %>
            <div class="notice" role="alert">
                <%= escapeHtml(loadError) %>
            </div>
        <% } else { %>
            <div class="notice">
                Live data loaded from your Oracle USERS table.
                Refresh this page to retrieve the latest records.
            </div>
        <% } %>

        <% if ("1".equals(deleted)) { %>
            <div class="user-action-message user-action-success" role="status">
                User account deactivated successfully.
            </div>
        <% } else if (error != null) { %>
            <div class="user-action-message user-action-error" role="alert">
                <% if ("invalid".equals(error)) { %>
                    Invalid user ID.
                <% } else if ("notfound".equals(error)) { %>
                    User not found, already deactivated, or protected.
                <% } else { %>
                    Unable to update the user account. Check the server log.
                <% } %>
            </div>
        <% } %>

        <section class="content-card">
            <div class="card-heading">
                <div>
                    <h2>Registered Accounts</h2>
                    <p class="card-description">Donor and NGO accounts.</p>
                </div>
            </div>

            <div class="toolbar">
                <input type="search"
                       id="tableSearch"
                       class="search-input"
                       placeholder="Search name, email or role..."
                       aria-label="Search users">
            </div>

            <div class="table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Account Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>

                    <tbody id="usersTableBody">
                    <% if (users != null && !users.isEmpty()) {
                           for (User user : users) { %>
                        <tr>
                            <td><%= user.getUserId() %></td>
                            <td><%= escapeHtml(user.getFullName()) %></td>
                            <td><%= escapeHtml(user.getEmail()) %></td>
                            <td><%= escapeHtml(user.getRole()) %></td>
                            <td><%= escapeHtml(user.getStatus()) %></td>
                            <td class="user-action-cell">
                                <% if (!"ADMIN".equalsIgnoreCase(user.getRole())) { %>
                                    <form method="post"
                                          action="<%= request.getContextPath() %>/admin/delete-user"
                                          onsubmit="return confirm('Are you sure you want to deactivate this user account?');">
                                        <input type="hidden"
                                               name="userId"
                                               value="<%= user.getUserId() %>">
                                        <button type="submit" class="user-delete-button">
                                            Delete
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span class="user-protected-label">Protected</span>
                                <% } %>
                            </td>
                        </tr>
                    <%     }
                       } else if (users != null) { %>
                        <tr>
                            <td colspan="6" class="empty-state">
                                No registered accounts found.
                            </td>
                        </tr>
                    <% } else { %>
                        <tr>
                            <td colspan="6" class="empty-state">
                                User records could not be loaded.
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <% if (users != null) { %>
                <p class="card-description" id="userCount">
                    Total accounts: <%= users.size() %>
                </p>
            <% } %>
        </section>

        <footer class="page-footer">
            &copy; <span id="currentYear"></span> FoodLoop Admin Panel
        </footer>

    </main>
</div>

<script src="../js/admin.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const searchInput = document.getElementById("tableSearch");
    const tableBody = document.getElementById("usersTableBody");
    const countElement = document.getElementById("userCount");

    if (searchInput && tableBody) {
        searchInput.addEventListener("input", function () {
            const term = this.value.toLowerCase().trim();
            const rows = tableBody.querySelectorAll("tr");
            let count = 0;

            rows.forEach(function (row) {
                if (row.cells.length !== 6) {
                    row.style.display = term ? "none" : "";
                    return;
                }

                const matches = row.textContent.toLowerCase().includes(term);
                row.style.display = matches ? "" : "none";

                if (matches) {
                    count++;
                }
            });

            if (countElement) {
                countElement.textContent =
                    "Showing " + count + " matching account(s)";
            }
        });
    }

    const year = document.getElementById("currentYear");
    if (year) {
        year.textContent = new Date().getFullYear();
    }
});
</script>

</body>
</html>
```