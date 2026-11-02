<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Résultats</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #eee; padding: 12px; text-align: left; }
        th { background: #1a73e8; color: white; }
    </style>
</head>
<body>
    <h2>Résultats filtrés</h2>
    <table>
        <tr>
            <th>Hôtel</th>
            <th>Ville</th>
            <th>Chaîne</th>
            <th>Étoiles</th>
            <th>Chambre #</th>
            <th>Prix</th>
            <th>Taille</th>
            <th>Action</th>
        </tr>
        <%
            String city = request.getParameter("city");
            String chain = request.getParameter("chain");
            int rating = Integer.parseInt(request.getParameter("rating"));
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            double maxPrice = Double.parseDouble(request.getParameter("max_price"));
            int minSize = Integer.parseInt(request.getParameter("min_size"));
            
            // On récupère les dates envoyées par index.html
            String dateStart = request.getParameter("date_start");
            String dateEnd = request.getParameter("date_end");

            if (dateStart != null && dateEnd != null) {
                try {
                    Class.forName("org.postgresql.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "radan066");

                    // LA REQUÊTE MISE À JOUR : Ajout du "NOT IN" pour vérifier la disponibilité
                    String sql = "SELECT h.*, r.* FROM hotel h JOIN hotel_room r ON h.hotel_number = r.hotel_number " +
             "WHERE h.city = ? AND h.rating >= ? AND r.capacity >= ? AND r.price <= ? AND r.superficie >= ? " +
             "AND CAST(r.room_number AS VARCHAR) NOT IN (" +
             "    SELECT CAST(res.room_number AS VARCHAR) FROM reservation res " +
             "    WHERE res.start_date < ? AND res.end_date > ?" +
             ")";
                    
                    // Si une chaîne spécifique est choisie
                    if (!"Tous".equals(chain)) {
                        sql += " AND h.chain_name = '" + chain + "'";
                    }

                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setString(1, city);
                    stmt.setInt(2, rating);
                    stmt.setInt(3, capacity);
                    stmt.setDouble(4, maxPrice);
                    stmt.setInt(5, minSize);
                    
                    // On injecte les dates pour la sous-requête (Attention à l'ordre : Fin d'abord, Début ensuite)
                    stmt.setDate(6, Date.valueOf(dateEnd));
                    stmt.setDate(7, Date.valueOf(dateStart));

                    ResultSet rs = stmt.executeQuery();
                    boolean found = false;
                    
                    while(rs.next()) {
                        found = true;
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("name") + "</td>");
                        out.println("<td>" + rs.getString("city") + "</td>");
                        out.println("<td>" + rs.getString("chain_name") + "</td>");
                        out.println("<td>" + rs.getInt("rating") + "⭐</td>");
                        out.println("<td>" + rs.getString("room_number") + "</td>");
                        out.println("<td>" + rs.getDouble("price") + "$</td>");
                        out.println("<td>" + rs.getInt("superficie") + "m²</td>");
                        
                        // On passe start et end dans l'URL pour reservation.jsp
                        out.println("<td><a href='reservation.jsp?hotel="+rs.getString("name")+"&room="+rs.getString("room_number")+"&start="+dateStart+"&end="+dateEnd+"'>Réserver</a></td>");
                        
                        out.println("</tr>");
                    }
                    
                    if (!found) {
                        out.println("<tr><td colspan='8' style='text-align:center;'>Aucune chambre n'est disponible pour ces dates et critères.</td></tr>");
                    }
                    
                    conn.close();
                } catch(Exception e) { 
                    out.println("<tr><td colspan='8' style='color:red;'>Erreur : " + e.getMessage() + "</td></tr>"); 
                }
            } else {
                out.println("<tr><td colspan='8' style='color:red;'>Erreur : Veuillez sélectionner des dates valides.</td></tr>");
            }
        %>
    </table>
</body>
</html>