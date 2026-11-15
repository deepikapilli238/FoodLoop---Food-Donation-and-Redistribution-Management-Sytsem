
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.foodloop.util.DBConnection" %>

<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private int getCount(Connection con, String sql) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userRole = String.valueOf(session.getAttribute("userRole"));

    if (!"ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("userName");

    if (adminName == null || adminName.trim().isEmpty()) {
        adminName = "Admin";
    }

    int totalUsers = 0;
    int totalDonors = 0;
    int totalNgos = 0;
    int totalAdmins = 0;

    int totalDonations = 0;
    int availableDonations = 0;

    int totalRequests = 0;
    int pendingRequests = 0;
    int acceptedRequests = 0;
    int rejectedRequests = 0;

    boolean databaseError = false;

    Connection con = null;

    try {
        con = DBConnection.getConnection();

        if (con == null) {
            throw new SQLException("Database connection returned null.");
        }

        // User statistics
        totalUsers = getCount(
            con,
            "SELECT COUNT(*) FROM USERS"
        );

        totalDonors = getCount(
            con,
            "SELECT COUNT(*) FROM USERS WHERE UPPER(ROLE) = 'DONOR'"
        );

        totalNgos = getCount(
            con,
            "SELECT COUNT(*) FROM USERS WHERE UPPER(ROLE) = 'NGO'"
        );

        totalAdmins = getCount(
            con,
            "SELECT COUNT(*) FROM USERS WHERE UPPER(ROLE) = 'ADMIN'"
        );

        // Donation statistics
        totalDonations = getCount(
            con,
            "SELECT COUNT(*) FROM DONATIONS"
        );

        availableDonations = getCount(
            con,
            "SELECT COUNT(*) FROM DONATIONS WHERE UPPER(STATUS) = 'AVAILABLE'"
        );

        // Request statistics
        totalRequests = getCount(
            con,
            "SELECT COUNT(*) FROM FOOD_REQUESTS"
        );

        pendingRequests = getCount(
            con,
            "SELECT COUNT(*) FROM FOOD_REQUESTS WHERE UPPER(STATUS) = 'PENDING'"
        );

        acceptedRequests = getCount(
            con,
            "SELECT COUNT(*) FROM FOOD_REQUESTS WHERE UPPER(STATUS) = 'ACCEPTED'"
        );

        rejectedRequests = getCount(
            con,
            "SELECT COUNT(*) FROM FOOD_REQUESTS WHERE UPPER(STATUS) = 'REJECTED'"
        );

    } catch (Exception e) {
        databaseError = true;
        application.log("Error loading FoodLoop statistics.", e);
    } finally {
        if (con != null) {
            try {
                con.close();
            } catch (SQLException e) {
                application.log("Could not close statistics connection.", e);
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Statistics | FoodLoop Admin</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/admin.css">
</head>

<body>

<div class="admin-layout">

    <!-- Sidebar -->
    <aside class="sidebar">

        <a class="brand"
           href="<%= request.getContextPath() %>/admin/dashboard.jsp">
            FoodLoop
            <span style="display:block; font-size:14px; font-weight:400;">
                Admin Panel
            </span>
        </a>

        <nav class="sidebar-nav">

            <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">
                Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/admin/manage-users.jsp">
                Manage Users
            </a>

            <a href="<%= request.getContextPath() %>/admin/manage-donations.jsp">
                Manage Donations
            </a>

            <a href="<%= request.getContextPath() %>/admin/manage-requests.jsp">
                Manage Requests
            </a>

            <a class="active"
               href="<%= request.getContextPath() %>/admin/statistics.jsp">
                Statistics
            </a>

            <a class="logout-link"
               href="<%= request.getContextPath() %>/logout">
                ↪ Logout
            </a>

        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">

        <header class="topbar">
            <div>
                <h1 class="page-title">Statistics</h1>
                <p class="page-subtitle">
                    Overview of FoodLoop users, donations and requests.
                </p>
            </div>

            <div class="admin-profile">
                <div>
                    <div class="profile-name">
                        <%= escapeHtml(adminName) %>
                    </div>
                    <div class="profile-role">Administrator</div>
                </div>
            </div>
        </header>

        <% if (databaseError) { %>

            <div class="notice">
                <strong>Unable to load statistics.</strong>
                <p>
                    Check the Eclipse Tomcat Console for the database error.
                    The displayed figures are not available until the query
                    succeeds.
                </p>
            </div>

        <% } else { %>

            <!-- Overall Statistics -->
            <section class="content-card">

                <div class="card-heading">
                    <div>
                        <h2>Platform Overview</h2>
                        <p class="card-description">
                            Current totals from the FoodLoop database.
                        </p>
                    </div>
                </div>

                <div class="stats-grid">

                    <div class="stat-card">
                        <div class="stat-label">Total Users</div>
                        <div class="stat-value"><%= totalUsers %></div>
                        <div class="stat-note">All registered accounts</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Total Donations</div>
                        <div class="stat-value"><%= totalDonations %></div>
                        <div class="stat-note">Records in DONATIONS</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Available Donations</div>
                        <div class="stat-value"><%= availableDonations %></div>
                        <div class="stat-note">Currently marked AVAILABLE</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Total Requests</div>
                        <div class="stat-value"><%= totalRequests %></div>
                        <div class="stat-note">Records in FOOD_REQUESTS</div>
                    </div>

                </div>

            </section>

            <!-- User Statistics -->
            <section class="content-card">

                <div class="card-heading">
                    <div>
                        <h2>User Statistics</h2>
                        <p class="card-description">
                            Registered accounts grouped by role.
                        </p>
                    </div>
                </div>

                <div class="stats-grid">

                    <div class="stat-card">
                        <div class="stat-label">Donors</div>
                        <div class="stat-value"><%= totalDonors %></div>
                        <div class="stat-note">Accounts with DONOR role</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">NGOs</div>
                        <div class="stat-value"><%= totalNgos %></div>
                        <div class="stat-note">Accounts with NGO role</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Administrators</div>
                        <div class="stat-value"><%= totalAdmins %></div>
                        <div class="stat-note">Accounts with ADMIN role</div>
                    </div>

                </div>

            </section>

            <!-- Request Statistics -->
            <section class="content-card">

                <div class="card-heading">
                    <div>
                        <h2>Request Statistics</h2>
                        <p class="card-description">
                            Breakdown using the request statuses currently
                            stored in FOOD_REQUESTS.
                        </p>
                    </div>
                </div>

                <div class="stats-grid">

                    <div class="stat-card">
                        <div class="stat-label">Pending Requests</div>
                        <div class="stat-value"><%= pendingRequests %></div>
                        <div class="stat-note">Awaiting a decision</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Accepted Requests</div>
                        <div class="stat-value"><%= acceptedRequests %></div>
                        <div class="stat-note">Marked ACCEPTED</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-label">Rejected Requests</div>
                        <div class="stat-value"><%= rejectedRequests %></div>
                        <div class="stat-note">Marked REJECTED</div>
                    </div>

                </div>

            </section>

        <% } %>

        <footer class="page-footer">
            FoodLoop Admin Panel
        </footer>

    </main>

</div>

</body>
</html>
