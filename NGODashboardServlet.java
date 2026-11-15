
package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;
import com.foodloop.model.Donation;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ngo/dashboard")
public class NGODashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check whether the user is logged in
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Read the role using the exact attribute name set by LoginServlet
        Object roleObject = session.getAttribute("userRole");

        if (roleObject == null ||
            !"NGO".equalsIgnoreCase(roleObject.toString().trim())) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied. NGO account required."
            );
            return;
        }

        try {
            // Retrieve available donations from Oracle
            List<Donation> donations =
                donationDAO.getAvailableDonations();

            // TEMPORARY DIAGNOSTICS: Check donations retrieved by the servlet
            System.out.println(
                "NGO DASHBOARD - Donations found: " + donations.size()
            );

            for (Donation donation : donations) {
                System.out.println(
                    "NGO DASHBOARD - Food: " + donation.getFoodName()
                );
            }

            // Pass donations to the existing NGO dashboard JSP
            request.setAttribute("availableDonations", donations);

            // Forward to the JSP at its actual location
            request.getRequestDispatcher(
                "/ngo/ngo-dashboard.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve available food donations.",
                e
            );
        }
    }
}
