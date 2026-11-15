
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.foodloop.model.Donation" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.sql.Timestamp" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "-";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Object sessionUserId = session.getAttribute("userId");
    String userRole = String.valueOf(session.getAttribute("userRole"));

    if (sessionUserId == null || !"DONOR".equalsIgnoreCase(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Donation> donations =
        (List<Donation>) request.getAttribute("donations");

    if (donations == null) {
        response.sendRedirect(
            request.getContextPath() + "/donor/my-donations"
        );
        return;
    }

    String saved = request.getParameter("saved");
    String message = request.getParameter("message");

    DateTimeFormatter dateFormatter =
        DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Donations | FoodLoop</title>

    <style>
        :root {
            --primary: #15803d;
            --primary-dark: #166534;
            --primary-light: #22c55e;
            --cream: #f8faf5;
            --white: #ffffff;
            --text: #1f2937;
            --muted: #64748b;
            --border: #e5e7eb;
            --shadow: 0 10px 35px rgba(21, 128, 61, 0.09);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
            scroll-padding-top: 85px;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: var(--cream);
            color: var(--text);
            line-height: 1.6;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button {
            font: inherit;
        }

        .navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.97);
            border-bottom: 1px solid var(--border);
        }

        .nav-container {
            width: min(1160px, 90%);
            min-height: 76px;
            margin: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
        }

        .logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: var(--primary);
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -1px;
            white-space: nowrap;
        }

        .logo-icon {
            display: grid;
            place-items: center;
            width: 43px;
            height: 43px;
            background: #dcfce7;
            border-radius: 13px;
            font-size: 25px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 28px;
        }

        .nav-links a {
            color: #475569;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .nav-links a:hover,
        .nav-links a.active {
            color: var(--primary);
        }

        .nav-links .logout-link {
            color: #b91c1c;
        }

        .donations-container {
            width: min(1400px, 90%);
            margin: auto;
            padding: 55px 0 80px;
        }

        .page-heading {
            margin-bottom: 35px;
        }

        .section-label {
            display: inline-block;
            color: var(--primary);
            background: #dcfce7;
            border-radius: 30px;
            padding: 6px 15px;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 14px;
        }

        .donations-heading {
            color: #163b25;
            font-size: clamp(34px, 4vw, 46px);
            line-height: 1.2;
            margin-bottom: 14px;
            letter-spacing: -1px;
        }

        .donations-subtitle {
            color: var(--muted);
            font-size: 17px;
            line-height: 1.8;
        }

        .page-actions {
            display: flex;
            justify-content: flex-start;
            margin-bottom: 28px;
        }

        .add-donation-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            padding: 14px 22px;
            background: var(--primary);
            color: var(--white);
            border: 1px solid transparent;
            border-radius: 9px;
            font-size: 15px;
            font-weight: 700;
            transition: transform 0.2s, background 0.2s;
        }

        .add-donation-button:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
        }

        .success-message {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 17px 20px;
            margin-bottom: 25px;
            border: 1px solid #bbf7d0;
            border-radius: 12px;
            background: #f0fdf4;
            color: var(--primary-dark);
            font-size: 14px;
            font-weight: 600;
        }

        .error-message {
            padding: 17px 20px;
            margin-bottom: 25px;
            border: 1px solid #fecaca;
            border-radius: 12px;
            background: #fef2f2;
            color: #991b1b;
            font-size: 14px;
            font-weight: 600;
        }

        .success-icon {
            font-size: 22px;
        }

        .donations-table-wrapper {
            overflow-x: auto;
            padding: 24px;
            border: 1px solid #e8f2e9;
            border-radius: 20px;
            background: #fffdf5;
            box-shadow: var(--shadow);
        }

        .table-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            margin-bottom: 25px;
        }

        .table-heading h2 {
            color: #163b25;
            font-size: 25px;
            line-height: 1.4;
        }

        .table-heading p {
            margin-top: 5px;
            color: var(--muted);
            font-size: 14px;
        }

        .donation-count {
            padding: 8px 13px;
            border-radius: 30px;
            background: #dcfce7;
            color: var(--primary-dark);
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
        }

        .donations-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        .donations-table th {
            padding: 22px 19px;
            background: var(--primary-dark);
            color: white;
            font-size: 14px;
            font-weight: 700;
            text-align: left;
            white-space: nowrap;
        }

        .donations-table th:first-child {
            border-radius: 9px 0 0 0;
        }

        .donations-table th:last-child {
            border-radius: 0 9px 0 0;
        }

        .donations-table td {
            padding: 21px 19px;
            border-bottom: 1px solid #e8e8df;
            color: var(--text);
            font-size: 15px;
            vertical-align: middle;
        }

        .donations-table tbody tr {
            transition: background 0.2s;
        }

        .donations-table tbody tr:hover {
            background: #f0fdf4;
        }

        .donations-table tbody tr:last-child td {
            border-bottom: none;
        }

        .food-name {
            color: #163b25;
            font-weight: 700;
        }

        .food-type {
            color: var(--muted);
        }

        .donation-status {
            display: inline-block;
            padding: 8px 13px;
            border-radius: 30px;
            background: #dcfce7;
            color: var(--primary-dark);
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .view-button {
            display: inline-block;
            padding: 9px 14px;
            background: var(--primary);
            color: white;
            border-radius: 7px;
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
            transition: background 0.2s;
        }

        .view-button:hover {
            background: var(--primary-dark);
        }

        .empty-donations {
            padding: 60px 20px;
            text-align: center;
        }

        .empty-icon {
            display: grid;
            place-items: center;
            width: 85px;
            height: 85px;
            margin: 0 auto 20px;
            border-radius: 24px;
            background: #dcfce7;
            font-size: 42px;
        }

        .empty-donations h2 {
            margin-bottom: 10px;
            color: #163b25;
            font-size: 25px;
        }

        .empty-donations p {
            max-width: 450px;
            margin: 0 auto 24px;
            color: var(--muted);
            font-size: 15px;
            line-height: 1.8;
        }

        .bottom-note {
            margin-top: 25px;
            color: var(--muted);
            font-size: 13px;
            text-align: center;
        }

        a:focus-visible,
        button:focus-visible {
            outline: 3px solid #f59e0b;
            outline-offset: 4px;
        }

        @media (max-width: 760px) {
            .nav-container {
                width: 92%;
                min-height: 70px;
                flex-wrap: wrap;
                padding: 12px 0;
            }

            .logo {
                font-size: 23px;
                gap: 6px;
            }

            .logo-icon {
                width: 38px;
                height: 38px;
                font-size: 22px;
            }

            .nav-links {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
                gap: 18px;
                padding-bottom: 8px;
            }

            .donations-container {
                width: 92%;
                padding: 32px 0 50px;
            }

            .donations-heading {
                font-size: 34px;
            }

            .donations-subtitle {
                font-size: 15px;
            }

            .donations-table-wrapper {
                padding: 16px;
                border-radius: 15px;
            }

            .table-heading h2 {
                font-size: 22px;
            }

            .donations-table th,
            .donations-table td {
                padding: 16px 13px;
                font-size: 13px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

<header class="navbar">
    <div class="nav-container">

        <a class="logo"
           href="<%= contextPath %>/donor/donor-dashboard.jsp">
            <span class="logo-icon">🌱</span>
            <span>FoodLoop</span>
        </a>

        <nav class="nav-links" aria-label="Main navigation">

            <a href="<%= contextPath %>/donor/donor-dashboard.jsp">
                Dashboard
            </a>

            <a href="<%= contextPath %>/donor/my-donations"
               class="active">
                My Donations
            </a>

            <a href="<%= contextPath %>/logout"
               class="logout-link">
                Logout
            </a>

        </nav>
    </div>
</header>

<main class="donations-container">

    <section class="page-heading">

        <span class="section-label">YOUR CONTRIBUTIONS</span>

        <h1 class="donations-heading">My Donations 🌱</h1>

        <p class="donations-subtitle">
            Manage and track the food donations you have shared
            through FoodLoop.
        </p>

    </section>

    <% if ("updated".equals(message)) { %>
        <div class="success-message" role="status">
            <span class="success-icon">✅</span>
            <span>Your donation details were updated successfully.</span>
        </div>
    <% } else if ("notfound".equals(message)) { %>
        <div class="error-message" role="alert">
            The selected donation could not be found. Please select a donation from your list.
        </div>
    <% } else if ("failed".equals(message)) { %>
        <div class="error-message" role="alert">
            The donation could not be updated. Please try again.
        </div>
    <% } else if ("success".equals(saved)) { %>
        <div class="success-message" role="status">
            <span class="success-icon">✅</span>
            <span>Your food donation has been saved successfully!</span>
        </div>
    <% } %>

    <div class="page-actions">
        <a class="add-donation-button"
           href="<%= contextPath %>/donor/add-donation.jsp">
            <span>＋</span>
            Add New Donation
        </a>
    </div>

    <% if (donations.isEmpty()) { %>

        <section class="donations-table-wrapper empty-donations">

            <div class="empty-icon">🥗</div>

            <h2>No donations yet</h2>

            <p>
                Your food donations will appear here after you submit
                them. Start sharing surplus food and make a difference
                in your community.
            </p>

            <a class="add-donation-button"
               href="<%= contextPath %>/donor/add-donation.jsp">
                ＋ Donate Food
            </a>

        </section>

    <% } else { %>

        <section class="donations-table-wrapper">

            <div class="table-heading">

                <div>
                    <h2>Donation History</h2>
                    <p>
                        View the food you have shared with your community.
                    </p>
                </div>

                <span class="donation-count">
                    <%= donations.size() %>
                    <%= donations.size() == 1 ? "Donation" : "Donations" %>
                </span>

            </div>

            <table class="donations-table">

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Food Name</th>
                        <th>Food Type</th>
                        <th>Quantity</th>
                        <th>Pickup Address</th>
                        <th>Expiry</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

                <% for (Donation donation : donations) { %>

                    <tr>

                        <td>
                            <%= donation.getDonationId() %>
                        </td>

                        <td class="food-name">
                            <%= escapeHtml(donation.getFoodName()) %>
                        </td>

                        <td class="food-type">
                            <%= escapeHtml(donation.getFoodType()) %>
                        </td>

                        <td>
                            <%= donation.getQuantity() %>
                        </td>

                        <td>
                            <%= escapeHtml(donation.getPickupAddress()) %>
                        </td>

                        <td>
                            <%
                                Timestamp expiry = donation.getExpiryTime();

                                if (expiry != null) {
                                    out.print(
                                        expiry.toLocalDateTime()
                                              .format(dateFormatter)
                                    );
                                } else {
                                    out.print("Not specified");
                                }
                            %>
                        </td>

                        <td>
                            <span class="donation-status">
                                <%= escapeHtml(donation.getStatus()) %>
                            </span>
                        </td>

                        <td>
                            <a class="view-button"
                               href="<%= contextPath %>/donor/donation-details?donationId=<%= donation.getDonationId() %>">
                                View Details
                            </a>
                        </td>

                    </tr>

                <% } %>

                </tbody>
            </table>

        </section>

    <% } %>

    <p class="bottom-note">
        Every donation matters. Thank you for helping reduce food waste. 💚
    </p>

</main>

</body>
</html>
