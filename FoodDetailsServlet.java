package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;
import com.foodloop.model.Donation;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ngo/food-details")
public class FoodDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Check whether the user is logged in
        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );

            return;
        }

        // Check whether the logged-in user is an NGO
        Object roleObject = session.getAttribute("userRole");

        if (roleObject == null ||
            !"NGO".equalsIgnoreCase(roleObject.toString().trim())) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied. NGO account required."
            );

            return;
        }

        // Get the donation ID from the URL
        String idParameter = request.getParameter("donationId");

        if (idParameter == null ||
            idParameter.trim().isEmpty()) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Donation ID is required."
            );

            return;
        }

        int donationId;

        try {

            donationId = Integer.parseInt(idParameter.trim());

            if (donationId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {

            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid donation ID."
            );

            return;
        }

        System.out.println(
            "FOOD DETAILS - Requested Donation ID: " + donationId
        );

        try {

            // Retrieve the exact donation selected by the NGO
            Donation donation =
                donationDAO.getAvailableDonationById(donationId);

            // Check whether the donation exists and is available
            if (donation == null) {

                System.out.println(
                    "FOOD DETAILS - Donation not found or unavailable: "
                    + donationId
                );

                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "The selected donation is unavailable or has expired."
                );

                return;
            }

            System.out.println(
                "FOOD DETAILS - Selected Food: "
                + donation.getFoodName()
            );

            System.out.println(
                "FOOD DETAILS - Selected Donation ID: "
                + donation.getDonationId()
            );

            // Pass the selected donation to food-details.jsp
            request.setAttribute("donation", donation);

            // Forward the request to the existing JSP
            request.getRequestDispatcher(
                "/ngo/food-details.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            throw new ServletException(
                "Unable to retrieve the selected food donation.",
                e
            );
        }
    }
}