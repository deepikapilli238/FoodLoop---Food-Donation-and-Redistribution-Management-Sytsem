
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map,java.text.SimpleDateFormat,java.sql.Timestamp" %>
<%
    String contextPath = request.getContextPath();

    List<Map<String, Object>> myRequests =
        (List<Map<String, Object>>) request.getAttribute("myRequests");

    if (myRequests == null) {
        myRequests = new java.util.ArrayList<Map<String, Object>>();
    }

    int totalRequests = myRequests.size();
    int pendingCount = 0;
    int acceptedCount = 0;
    int completedCount = 0;
    int rejectedCount = 0;

    for (Map<String, Object> item : myRequests) {
        String status = String.valueOf(item.get("STATUS"));

        if ("PENDING".equalsIgnoreCase(status)) {
            pendingCount++;
        } else if ("ACCEPTED".equalsIgnoreCase(status)
                || "APPROVED".equalsIgnoreCase(status)) {
            acceptedCount++;
        } else if ("COMPLETED".equalsIgnoreCase(status)) {
            completedCount++;
        } else if ("REJECTED".equalsIgnoreCase(status)) {
            rejectedCount++;
        }
    }

    SimpleDateFormat dateFormat =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Requests | FoodLoop</title>
    <link rel="stylesheet" href="<%= contextPath %>/css/ngo.css">
    <script src="<%= contextPath %>/js/ngo.js" defer></script>
</head>
<body>

<div class="dashboard-layout">

    <aside class="sidebar">
        <a class="brand" href="<%= contextPath %>/ngo/ngo-dashboard.jsp">FoodLoop<span>.</span></a>

        <p class="sidebar-label">NGO MENU</p>

        <nav>
            <a class="nav-link" href="<%= contextPath %>/ngo/ngo-dashboard.jsp">🏠 Dashboard</a>
            <a class="nav-link" href="<%= contextPath %>/ngo/available-food">🍱 Available Food</a>
            <a class="nav-link active" href="<%= contextPath %>/ngo/my-requests">📩 My Requests</a>
            <a class="nav-link" href="<%= contextPath %>/ngo/pickup-status.jsp">🚚 Pickup Status</a>
        </nav>

        <a class="nav-link logout-link" href="<%= contextPath %>/index.html">↩ Back to Home</a>
    </aside>

    <main class="main-content">

        <header class="topbar">
            <div>
                <h1>My Food Requests</h1>
                <p class="muted">View the status of food donations requested by your NGO.</p>
            </div>
            <div class="profile-badge">N</div>
        </header>

        <section class="stats-grid request-stats">

            <article class="stat-card">
                <p>Total Requests</p>
                <h2><%= totalRequests %></h2>
            </article>

            <article class="stat-card">
                <p>Pending</p>
                <h2><%= pendingCount %></h2>
            </article>

            <article class="stat-card">
                <p>Accepted</p>
                <h2><%= acceptedCount %></h2>
            </article>

            <article class="stat-card">
                <p>Completed</p>
                <h2><%= completedCount %></h2>
            </article>

        </section>

        <section class="content-card">

            <div class="filter-bar">
                <input
                    type="search"
                    id="requestSearch"
                    placeholder="Search food or request ID..."
                    aria-label="Search requests">

                <select id="requestStatusFilter" aria-label="Filter by request status">
                    <option value="all">All Statuses</option>
                    <option value="pending">Pending</option>
                    <option value="accepted">Accepted</option>
                    <option value="completed">Completed</option>
                    <option value="rejected">Rejected</option>
                </select>
            </div>

            <div class="table-wrapper">
                <table id="requestsTable">

                    <thead>
                        <tr>
                            <th>Request ID</th>
                            <th>Food Item</th>
                            <th>Quantity</th>
                            <th>Request Date</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>

                    <tbody>
                    <%
                        for (Map<String, Object> item : myRequests) {

                            Object requestId = item.get("REQUEST_ID");
                            Object foodName = item.get("FOOD_NAME");
                            Object quantity = item.get("REQUESTED_QUANTITY");
                            Object requestDate = item.get("REQUEST_DATE");

                            String status = String.valueOf(item.get("STATUS"));
                            String normalizedStatus = status.toLowerCase();

                            String statusClass = normalizedStatus;
                            String displayStatus = status;

                            if ("approved".equalsIgnoreCase(status)) {
                                statusClass = "accepted";
                                displayStatus = "Accepted";
                            } else if ("accepted".equalsIgnoreCase(status)) {
                                displayStatus = "Accepted";
                            } else if ("pending".equalsIgnoreCase(status)) {
                                displayStatus = "Pending";
                            } else if ("rejected".equalsIgnoreCase(status)) {
                                displayStatus = "Rejected";
                            } else if ("completed".equalsIgnoreCase(status)) {
                                displayStatus = "Completed";
                            }

                            String formattedDate = "—";

                            if (requestDate instanceof Timestamp) {
                                formattedDate =
                                    dateFormat.format((Timestamp) requestDate);
                            } else if (requestDate instanceof java.util.Date) {
                                formattedDate =
                                    dateFormat.format((java.util.Date) requestDate);
                            } else if (requestDate != null) {
                                formattedDate = requestDate.toString();
                            }

                            String safeFoodName = foodName == null
                                ? "Food item"
                                : foodName.toString();

                            String safeQuantity = quantity == null
                                ? "—"
                                : quantity.toString();
                    %>
                        <tr data-status="<%= statusClass %>">

                            <td>
                                FL-R<%= requestId %>
                            </td>

                            <td>
                                <%= safeFoodName.replace("&", "&amp;")
                                    .replace("<", "&lt;")
                                    .replace(">", "&gt;")
                                    .replace("\"", "&quot;")
                                    .replace("'", "&#39;") %>
                            </td>

                            <td>
                                <%= safeQuantity %>
                            </td>

                            <td>
                                <%= formattedDate %>
                            </td>

                            <td>
                                <span class="status <%= statusClass %>">
                                    <%= displayStatus %>
                                </span>
                            </td>

                            <td>
                                <% if ("ACCEPTED".equalsIgnoreCase(status)
                                        || "APPROVED".equalsIgnoreCase(status)
                                        || "COMPLETED".equalsIgnoreCase(status)) { %>
                                    <a class="table-link"
                                       href="<%= contextPath %>/ngo/pickup-status.jsp">Track</a>
                                <% } else if ("REJECTED".equalsIgnoreCase(status)) { %>
                                    <a class="table-link"
                                       href="<%= contextPath %>/ngo/available-food">Find Food</a>
                                <% } else { %>
                                    <span class="muted">Awaiting donor</span>
                                <% } %>
                            </td>

                        </tr>
                    <%
                        }
                    %>
                    </tbody>

                </table>
            </div>

            <p id="noRequests" class="empty-message"
               <%= myRequests.isEmpty() ? "" : "hidden" %>>
                <%= myRequests.isEmpty()
                    ? "You have not submitted any food requests yet."
                    : "No matching requests found." %>
            </p>

        </section>

        <footer class="page-footer">© 2026 FoodLoop</footer>

    </main>
</div>

</body>
</html>
