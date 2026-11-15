<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Dashboard | FoodLoop</title>
    <link rel="stylesheet" href="../css/donor.css">
    <script src="../js/donor.js" defer></script>
</head>
<body>

<div class="dashboard-layout">

    <aside class="sidebar">
        <a class="brand" href="donor-dashboard.jsp">FoodLoop<span>.</span></a>
        <p class="sidebar-label">DONOR MENU</p>

        <nav>
            <a class="nav-link active" href="donor-dashboard.jsp">🏠 Dashboard</a>
            <a class="nav-link" href="add-donation.jsp">➕ Add Donation</a>
            <a class="nav-link" href="my-donations.jsp">🍱 My Donations</a>
            <a class="nav-link" href="donation-requests.jsp">📩 Donation Requests</a>
            <a class="nav-link" href="donation-details.jsp">📋 Donation Details</a>
        </nav>

        <a class="nav-link logout-link" href="../index.html">↩ Back to Home</a>
    </aside>

    <main class="main-content">

        <header class="topbar">
            <div>
                <h1>Donor Dashboard</h1>
                <p class="muted">Welcome back! Let's make a difference today.</p>
            </div>
            <div class="profile-badge">D</div>
        </header>

        <section class="welcome-banner">
            <div>
                <p class="eyebrow">MAKE A DIFFERENCE</p>
                <h2>Share Food. Spread Hope. 🌱</h2>
                <p>Your surplus food can make someone's day better.</p>
                <a class="btn btn-light" href="add-donation.jsp">+ Donate Food</a>
            </div>
            <div class="banner-emoji">🥗</div>
        </section>

        <section class="stats-grid">
            <article class="stat-card">
                <div class="stat-icon">🍱</div>
                <p>Total Donations</p>
                <h2>24</h2>
                <span>All donations submitted</span>
            </article>

            <article class="stat-card">
                <div class="stat-icon">✅</div>
                <p>Completed Donations</p>
                <h2>16</h2>
                <span>Successfully distributed</span>
            </article>

            <article class="stat-card">
                <div class="stat-icon">⏳</div>
                <p>Pending Donations</p>
                <h2>5</h2>
                <span>Awaiting collection</span>
            </article>

            <article class="stat-card">
                <div class="stat-icon">📩</div>
                <p>Incoming Requests</p>
                <h2>3</h2>
                <span>Requests to review</span>
            </article>
        </section>

        <section class="content-card">
            <div class="section-heading">
                <div>
                    <h2>Recent Donations</h2>
                    <p class="muted">A quick overview of your recent contributions.</p>
                </div>
                <a class="text-link" href="my-donations.jsp">View All →</a>
            </div>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Food Item</th>
                            <th>Quantity</th>
                            <th>Expiry</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Cooked Rice</td>
                            <td>10 servings</td>
                            <td>Today</td>
                            <td><span class="status pending">Pending</span></td>
                            <td><a class="table-link" href="donation-details.jsp">View</a></td>
                        </tr>
                        <tr>
                            <td>Vegetable Meals</td>
                            <td>15 servings</td>
                            <td>Tomorrow</td>
                            <td><span class="status approved">Approved</span></td>
                            <td><a class="table-link" href="donation-details.jsp">View</a></td>
                        </tr>
                        <tr>
                            <td>Bread Packets</td>
                            <td>20 packets</td>
                            <td>Tomorrow</td>
                            <td><span class="status completed">Completed</span></td>
                            <td><a class="table-link" href="donation-details.jsp">View</a></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="content-card">
            <div class="section-heading">
                <div>
                    <h2>Quick Actions</h2>
                    <p class="muted">Manage your food donations easily.</p>
                </div>
            </div>

            <div class="quick-actions">
                <a class="action-card" href="add-donation.jsp">
                    <span>➕</span>
                    <h3>Add a Donation</h3>
                    <p>Share available surplus food.</p>
                </a>

                <a class="action-card" href="my-donations.jsp">
                    <span>🍱</span>
                    <h3>My Donations</h3>
                    <p>View and manage your donations.</p>
                </a>

                <a class="action-card" href="donation-requests.jsp">
                    <span>📩</span>
                    <h3>Review Requests</h3>
                    <p>Check requests from organizations.</p>
                </a>
            </div>
        </section>

        <footer class="page-footer">
            © 2026 FoodLoop | Reducing Food Waste, Sharing Hope
        </footer>

    </main>
</div>

</body>
</html>