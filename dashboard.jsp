
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.foodloop.util.DBConnection" %>

<%!
    private int getCount(Connection connection, String sql)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
        }

        return 0;
    }

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
        response.sendRedirect(
            request.getContextPath() + "/login.jsp?unauthorized=1"
        );
        return;
    }

    String role = String.valueOf(session.getAttribute("userRole"));

    if (!"ADMIN".equalsIgnoreCase(role)) {
        response.sendError(
            HttpServletResponse.SC_FORBIDDEN,
            "Admin access required."
        );
        return;
    }

    Object nameObject = session.getAttribute("userName");
    String adminName = nameObject == null ? "Administrator"
            : nameObject.toString();

    int totalUsers = 0;
    int totalDonations = 0;
    int totalRequests = 0;
    int pendingRequests = 0;
    boolean databaseConnected = false;
    String databaseError = null;

    try (Connection connection = DBConnection.getConnection()) {
        databaseConnected = true;

        totalUsers = getCount(
            connection,
            "SELECT COUNT(*) FROM USERS"
        );

        totalDonations = getCount(
            connection,
            "SELECT COUNT(*) FROM DONATIONS"
        );

        totalRequests = getCount(
            connection,
            "SELECT COUNT(*) FROM FOOD_REQUESTS"
        );

        pendingRequests = getCount(
            connection,
            "SELECT COUNT(*) FROM FOOD_REQUESTS WHERE UPPER(STATUS) = 'PENDING'"
        );

    } catch (SQLException e) {
        application.log("Unable to load admin dashboard statistics", e);
        databaseError = "Unable to load live statistics. Please check the database connection and server logs.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | FoodLoop</title>
    <link rel="stylesheet" href="../css/admin.css">
</head>

<body>
<div class="admin-layout">

    <aside class="sidebar">
        <a href="dashboard.jsp" class="brand">Food<span>Loop</span></a>

        <p class="sidebar-label">Administration</p>

        <button type="button"
                id="mobileMenuButton"
                class="mobile-menu-button"
                aria-expanded="false"
                aria-controls="sidebarNav">
            ☰ Menu
        </button>

        <nav class="sidebar-nav open" id="sidebarNav">
            <a class="active" href="dashboard.jsp">▦ Dashboard</a>
            <a href="manage-users.jsp">♙ Manage Users</a>
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
                <h1 class="page-title">Admin Dashboard</h1>
                <p class="page-subtitle">
                    Welcome back! Monitor your FoodLoop platform.
                </p>
            </div>

            <div class="admin-profile">
                <div class="profile-icon">
                    <%= escapeHtml(
                        adminName.trim().isEmpty()
                            ? "A"
                            : adminName.substring(0, 1).toUpperCase()
                    ) %>
                </div>

                <div>
                    <p class="profile-name">
                        <%= escapeHtml(adminName) %>
                    </p>
                    <p class="profile-role">Administrator</p>
                </div>
            </div>
        </header>

        <% if (databaseConnected) { %>
            <div class="notice">
                Dashboard connected to your Oracle database. Statistics are
                updated whenever this page is loaded.
            </div>
        <% } else { %>
            <div class="notice" role="alert">
                <%= escapeHtml(databaseError) %>
            </div>
        <% } %>

        <section class="stats-grid">

            <article class="stat-card">
                <p class="stat-label">Total Users</p>
                <h2 class="stat-value">
                    <%= databaseConnected ? String.valueOf(totalUsers) : "—" %>
                </h2>
                <p class="stat-note">Registered platform accounts</p>
            </article>

            <article class="stat-card">
                <p class="stat-label">Total Donations</p>
                <h2 class="stat-value">
                    <%= databaseConnected ? String.valueOf(totalDonations) : "—" %>
                </h2>
                <p class="stat-note">Donation records in the database</p>
            </article>

            <article class="stat-card">
                <p class="stat-label">Food Requests</p>
                <h2 class="stat-value">
                    <%= databaseConnected ? String.valueOf(totalRequests) : "—" %>
                </h2>
                <p class="stat-note">Total submitted food requests</p>
            </article>

            <article class="stat-card">
                <p class="stat-label">Pending Requests</p>
                <h2 class="stat-value">
                    <%= databaseConnected ? String.valueOf(pendingRequests) : "—" %>
                </h2>
                <p class="stat-note">Requests awaiting a decision</p>
            </article>

        </section>

        <section class="content-card">

            <div class="card-heading">
                <div>
                    <h2>Admin Quick Actions</h2>
                    <p class="card-description">
                        Open a section to review FoodLoop data.
                    </p>
                </div>
            </div>

            <div class="quick-links">

                <a href="manage-users.jsp" class="quick-link">
                    <h3>♙ Manage Users</h3>
                    <p>Review registered donors and NGO accounts.</p>
                </a>

                <a href="manage-donations.jsp" class="quick-link">
                    <h3>♧ Manage Donations</h3>
                    <p>Monitor surplus food donation records.</p>
                </a>

                <a href="manage-requests.jsp" class="quick-link">
                    <h3>☷ Manage Requests</h3>
                    <p>Review requests submitted by NGOs.</p>
                </a>

                <a href="statistics.jsp" class="quick-link">
                    <h3>▤ Statistics</h3>
                    <p>View overall platform metrics.</p>
                </a>

            </div>
        </section>

        <footer class="page-footer">
            &copy; <span id="currentYear"></span> FoodLoop Admin Panel
        </footer>

    </main>
</div>

<script src="../js/admin.js"></script>

<script>
    document.getElementById("currentYear").textContent =
        new Date().getFullYear();
</script>

</body>
</html>
