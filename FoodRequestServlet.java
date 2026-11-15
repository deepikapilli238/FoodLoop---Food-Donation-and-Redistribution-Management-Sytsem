package com.foodloop.controller;

import com.foodloop.dao.FoodRequestDAO;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ngo/submit-request")
public class FoodRequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FoodRequestDAO foodRequestDAO =
            new FoodRequestDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        String role =
                String.valueOf(session.getAttribute("userRole"));

        if (!"NGO".equalsIgnoreCase(role)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only NGOs can submit food requests.");

            return;
        }

        String donationIdText =
                request.getParameter("donationId");

        String quantityText =
                request.getParameter("requestedQuantity");

        int donationId;
        int requestedQuantity;
        int ngoId;

        try {
            donationId =
                    Integer.parseInt(donationIdText);

            requestedQuantity =
                    Integer.parseInt(quantityText);

            Object sessionUserId =
                    session.getAttribute("userId");

            if (sessionUserId instanceof Number) {
                ngoId = ((Number) sessionUserId).intValue();
            } else {
                ngoId = Integer.parseInt(
                        String.valueOf(sessionUserId));
            }

            if (donationId <= 0 ||
                    ngoId <= 0 ||
                    requestedQuantity <= 0) {

                throw new NumberFormatException(
                        "IDs and quantity must be positive.");
            }

        } catch (NumberFormatException |
                 NullPointerException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/ngo/available-food?requestError=invalid");

            return;
        }

        try {

            foodRequestDAO.createRequest(
                    donationId,
                    ngoId,
                    requestedQuantity);

            response.sendRedirect(
                    request.getContextPath()
                    + "/ngo/food-details?donationId="
                    + donationId
                    + "&requestResult=success");

        } catch (IllegalArgumentException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/ngo/food-details?donationId="
                    + donationId
                    + "&requestResult=error");

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to save the food request.", e);
        }
    }
}