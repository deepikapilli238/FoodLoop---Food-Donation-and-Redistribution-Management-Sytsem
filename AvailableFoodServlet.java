
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

@WebServlet("/ngo/available-food")
public class AvailableFoodServlet extends HttpServlet {

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

        // Check NGO role
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
            // Fetch available donations from the database
            List<Donation> donations =
                donationDAO.getAvailableDonations();

            System.out.println(
                "AVAILABLE FOOD PAGE - Donations found: "
                + donations.size()
            );

            // Send donations to the JSP
            request.setAttribute("availableDonations", donations);

            // Display the existing Available Food page
            request.getRequestDispatcher(
                "/ngo/available-food.jsp"
            ).forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve available food donations.",
                e
            );
        }
    }
}
