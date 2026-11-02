<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- SÉCURITÉ ADMIN ---
    if ("true".equals(request.getParameter("logout"))) {
        session.removeAttribute("admin_logged");
        response.sendRedirect("admin.jsp");
        return;
    }

    if (session.getAttribute("admin_logged") == null) {
        if ("admin123".equals(request.getParameter("admin_pwd"))) {
            session.setAttribute("admin_logged", true);
            response.sendRedirect("admin.jsp");
            return;
        }
%>
        <!DOCTYPE html>
        <html>
        <head><style>body { font-family: sans-serif; text-align: center; margin-top: 100px; background: #343a40; color: white; } input, button { padding: 10px; }</style></head>
        <body>
            <h2>Accès Administrateur</h2>
            <form method="POST">
                <input type="password" name="admin_pwd" placeholder="Mot de passe Admin" required>
                <button type="submit">Entrer</button>
            </form>
            <br><a href="index.html" style="color:#17a2b8;">Retour au site</a>
        </body>
        </html>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Panneau d'Administration - e-Hotels</title>
    <style>
        body { font-family: sans-serif; margin: 30px; background-color: #f4f4f9; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { color: #333; border-bottom: 2px solid #6c757d; padding-bottom: 10px; }
        input, select { padding: 6px; margin: 5px 0; border: 1px solid #ccc; border-radius: 4px; }
        button { padding: 8px 12px; background: #007BFF; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight:bold;}
        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px;}
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #343a40; color: white; }
        .btn-del { background-color: #d9534f; color: white; padding: 4px 8px; text-decoration: none; border-radius: 4px; font-size: 11px; }
        .header-top { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #ddd; padding-bottom: 10px; margin-bottom: 20px;}
        .grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    </style>
</head>
<body>

    <div class="header-top">
        <h1>⚙️ Panneau d'Administration Global</h1>
        <div>
            <a href="index.html" style="background: #6c757d; color: white; padding: 8px 12px; text-decoration: none; border-radius: 4px; margin-right: 10px;">🏠 Accueil Site</a>
            <a href="admin.jsp?logout=true" style="background: #dc3545; color: white; padding: 8px 12px; text-decoration: none; border-radius: 4px;">Quitter l'Admin</a>
        </div>
    </div>

    <%
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "radan066");

            String action = request.getParameter("action");
            
            // --- LOGIQUE DE SUPPRESSION ---
            try {
                if ("del_room".equals(action)) {
                    // CORRECTION ICI : On enlève les apostrophes simples autour du numéro de chambre pour l'envoyer comme Integer
                    conn.createStatement().executeUpdate("DELETE FROM hotel_room WHERE room_number = " + request.getParameter("room") + " AND hotel_number = " + request.getParameter("hotel"));
                    out.println("<p style='color:green;'>✅ Chambre supprimée.</p>");
                } else if ("del_hotel".equals(action)) {
                    conn.createStatement().executeUpdate("DELETE FROM hotel WHERE hotel_number = " + request.getParameter("hotel"));
                    out.println("<p style='color:green;'>✅ Hôtel supprimé.</p>");
                } else if ("del_chain".equals(action)) {
                    conn.createStatement().executeUpdate("DELETE FROM hotel_chain WHERE chain_number = " + request.getParameter("chain"));
                    out.println("<p style='color:green;'>✅ Chaîne supprimée.</p>");
                }
            } catch(SQLException ex) {
                out.println("<p style='color:red; font-weight:bold;'>❌ Impossible de supprimer : Cette donnée est liée à d'autres éléments. Supprimez les éléments enfants d'abord.</p>");
            }

            // --- LOGIQUE D'AJOUT ---
            try {
                if ("add_chain".equals(action)) {
                    PreparedStatement ps = conn.prepareStatement("INSERT INTO hotel_chain (chain_number, name) VALUES (?, ?)");
                    ps.setInt(1, Integer.parseInt(request.getParameter("chain_id"))); 
                    ps.setString(2, request.getParameter("name"));
                    ps.executeUpdate();
                    out.println("<p style='color:green;'>✅ Chaîne ajoutée.</p>");
                } else if ("add_hotel".equals(action)) {
                    PreparedStatement ps = conn.prepareStatement("INSERT INTO hotel (hotel_number, chain_number, name, city) VALUES (?, ?, ?, ?)");
                    ps.setInt(1, Integer.parseInt(request.getParameter("hotel_id")));
                    ps.setInt(2, Integer.parseInt(request.getParameter("chain_id")));
                    ps.setString(3, request.getParameter("name"));
                    ps.setString(4, request.getParameter("city"));
                    ps.executeUpdate();
                    out.println("<p style='color:green;'>✅ Hôtel ajouté.</p>");
                } else if ("add_room".equals(action)) {
                    PreparedStatement ps = conn.prepareStatement("INSERT INTO hotel_room (hotel_number, room_number, capacity, price, superficie) VALUES (?, ?, ?, ?, ?)");
                    ps.setInt(1, Integer.parseInt(request.getParameter("hotel_id")));
                    // CORRECTION ICI : setInt au lieu de setString
                    ps.setInt(2, Integer.parseInt(request.getParameter("room_num"))); 
                    ps.setInt(3, Integer.parseInt(request.getParameter("capacity")));
                    ps.setDouble(4, Double.parseDouble(request.getParameter("price")));
                    ps.setInt(5, 30); // Superficie par défaut
                    ps.executeUpdate();
                    out.println("<p style='color:green;'>✅ Chambre ajoutée.</p>");
                }
            } catch(SQLException ex) {
                out.println("<p style='color:red;'>Erreur lors de l'ajout : " + ex.getMessage() + "</p>");
            }
    %>

    <div class="grid-container">
        <!-- SECTION CHAÎNES -->
        <div class="card">
            <h2>🏢 Chaînes d'Hôtels</h2>
            <form method="POST" style="margin-bottom: 10px;">
                <input type="hidden" name="action" value="add_chain">
                <input type="number" name="chain_id" placeholder="ID (ex: 1)" required style="width: 80px;">
                <input type="text" name="name" placeholder="Nom de la chaîne" required>
                <button type="submit">Ajouter</button>
            </form>
            <table>
                <tr><th>ID</th><th>Nom</th><th>Action</th></tr>
                <%
                    ResultSet rsC = conn.createStatement().executeQuery("SELECT * FROM hotel_chain ORDER BY chain_number");
                    while(rsC.next()){
                        out.println("<tr><td>" + rsC.getInt("chain_number") + "</td><td>" + rsC.getString("name") + "</td>");
                        out.println("<td><a href='admin.jsp?action=del_chain&chain=" + rsC.getInt("chain_number") + "' class='btn-del' onclick=\"return confirm('Supprimer ?');\">X</a></td></tr>");
                    }
                %>
            </table>
        </div>

        <!-- SECTION HÔTELS -->
        <div class="card">
            <h2>🏨 Hôtels</h2>
            <form method="POST" style="margin-bottom: 10px;">
                <input type="hidden" name="action" value="add_hotel">
                <input type="number" name="hotel_id" placeholder="ID Hôtel" required style="width: 80px;">
                <input type="number" name="chain_id" placeholder="ID Chaîne" required style="width: 80px;">
                <input type="text" name="name" placeholder="Nom de l'hôtel" required>
                <input type="text" name="city" placeholder="Ville" required>
                <button type="submit">Ajouter</button>
            </form>
            <table>
                <tr><th>ID</th><th>Chaîne ID</th><th>Nom</th><th>Ville</th><th>Action</th></tr>
                <%
                    ResultSet rsH = conn.createStatement().executeQuery("SELECT * FROM hotel ORDER BY hotel_number");
                    while(rsH.next()){
                        out.println("<tr><td>" + rsH.getInt("hotel_number") + "</td><td>" + rsH.getInt("chain_number") + "</td><td>" + rsH.getString("name") + "</td><td>" + rsH.getString("city") + "</td>");
                        out.println("<td><a href='admin.jsp?action=del_hotel&hotel=" + rsH.getInt("hotel_number") + "' class='btn-del' onclick=\"return confirm('Supprimer ?');\">X</a></td></tr>");
                    }
                %>
            </table>
        </div>
    </div>

    <!-- SECTION CHAMBRES -->
    <div class="card">
        <h2>🛏️ Chambres</h2>
        <form method="POST" style="margin-bottom: 10px;">
            <input type="hidden" name="action" value="add_room">
            <input type="number" name="hotel_id" placeholder="ID Hôtel" required>
            <input type="number" name="room_num" placeholder="Numéro Chambre (ex: 101)" required>
            <input type="number" name="capacity" placeholder="Capacité (ex: 2)" required>
            <input type="number" name="price" placeholder="Prix par nuit" required>
            <button type="submit">Ajouter</button>
        </form>
        <table>
            <tr><th>Hôtel ID</th><th>Chambre</th><th>Capacité</th><th>Prix</th><th>Action</th></tr>
            <%
                ResultSet rsR = conn.createStatement().executeQuery("SELECT * FROM hotel_room ORDER BY hotel_number, room_number");
                while(rsR.next()){
                    out.println("<tr><td>" + rsR.getInt("hotel_number") + "</td><td>" + rsR.getInt("room_number") + "</td><td>" + rsR.getInt("capacity") + " pers.</td><td>" + rsR.getDouble("price") + "$</td>");
                    out.println("<td><a href='admin.jsp?action=del_room&hotel=" + rsR.getInt("hotel_number") + "&room=" + rsR.getInt("room_number") + "' class='btn-del' onclick=\"return confirm('Supprimer cette chambre ?');\">Supprimer</a></td></tr>");
                }
            %>
        </table>
    </div>

    <% 
        } catch(Exception e) { out.println("<p style='color:red;'>Erreur globale : " + e.getMessage() + "</p>"); } 
        finally { if (conn != null) conn.close(); }
    %>
</body>
</html>