package com.foodloop.controller;

import com.foodloop.dao.FoodRequestDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ngo/my-requests")
public class NgoMyRequestsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final FoodRequestDAO foodRequestDAO = new FoodRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        // Check whether the NGO is logged in.
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Only NGO users can access this page.
        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"NGO".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only NGOs can view their food requests."
            );
            return;
        }

        int ngoId;

        try {
            ngoId = Integer.parseInt(
                    String.valueOf(session.getAttribute("userId"))
            );

            if (ngoId <= 0) {
                throw new NumberFormatException("Invalid NGO ID");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Fetch the NGO's latest requests from Oracle.
        try {
            List<Map<String, Object>> myRequests =
                    foodRequestDAO.getRequestsForNgo(ngoId);

            request.setAttribute("myRequests", myRequests);

            // Forward to the NGO My Requests JSP.
            request.getRequestDispatcher("/ngo/my-requests.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            getServletContext().log(
                    "Unable to load requests for NGO ID " + ngoId,
                    e
            );

            throw new ServletException(
                    "Unable to load your food requests. Check the server logs.",
                    e
            );
        }
    }
}