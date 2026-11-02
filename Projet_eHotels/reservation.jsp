<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Finaliser la Réservation</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f4f7f6; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); width: 450px; }
        h2 { color: #007BFF; text-align: center; }
        .info-hotel { background: #e9ecef; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; }
        label { display: block; margin-top: 15px; font-weight: bold; }
        input, select { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 5px; box-sizing: border-box; }
        .btn-confirm { width: 100%; padding: 12px; background: #28a745; color: white; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; margin-top: 20px; }
        .success-msg { text-align: center; color: #28a745; }
        .error-msg { text-align: center; color: #dc3545; }
    </style>
</head>
<body>
<div class="card">
    <%
        String hotelRaw = request.getParameter("hotel"); 
        String room = request.getParameter("room");
        String action = request.getParameter("action");
        String startStr = request.getParameter("start");
        String endStr = request.getParameter("end");

        // --- TRADUCTION DU NOM EN ID POUR ÉVITER L'ERREUR ---
        int hotelId = 0;
        if (hotelRaw != null) {
            // Si c'est déjà un chiffre, on le prend, sinon on cherche le mot-clé
            if (hotelRaw.matches("\\d+")) {
                hotelId = Integer.parseInt(hotelRaw);
            } else {
                if (hotelRaw.contains("Frontenac")) hotelId = 1;
                else if (hotelRaw.contains("Westin")) hotelId = 2;
                else if (hotelRaw.contains("Bonaventure")) hotelId = 3;
                else if (hotelRaw.contains("Ritz")) hotelId = 4;
                else if (hotelRaw.contains("Sheraton")) hotelId = 5;
                else if (hotelRaw.contains("Springs")) hotelId = 6;
                else if (hotelRaw.contains("Marriott")) hotelId = 7;
                else if (hotelRaw.contains("Alt Hotel")) hotelId = 8;
            }
        }

        if (action != null && action.equals("confirm")) {
            String nom = request.getParameter("nom");
            String adresse = request.getParameter("adresse");
            String idType = request.getParameter("id_type");

            Connection conn = null;
            try {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "radan066");
                
                // --- ÉTAPE 0 : VÉRIFICATION DES CONFLITS ---
                String sqlCheck = "SELECT COUNT(*) FROM reservation WHERE room_number = ? AND hotel_number = ? AND (start_date < ? AND end_date > ?)";
                PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheck);
                pstmtCheck.setString(1, room);
                pstmtCheck.setInt(2, hotelId); // Utilisation de hotelId converti
                pstmtCheck.setDate(3, Date.valueOf(endStr));
                pstmtCheck.setDate(4, Date.valueOf(startStr));
                
                ResultSet rsCheck = pstmtCheck.executeQuery();
                rsCheck.next();
                
                if (rsCheck.getInt(1) > 0) {
                    out.println("<div class='error-msg'><h2>⚠️ Chambre Indisponible</h2><p>Déjà réservée pour ces dates.</p><br><a href='index.html'>Retour</a></div>");
                } else {
                    // --- ÉTAPE 1 : Insertion du client ---
                    String sqlCustomer = "INSERT INTO customer (full_name, address, id_type) VALUES (?, ?, ?) RETURNING customer_id";
                    PreparedStatement pstmtCust = conn.prepareStatement(sqlCustomer);
                    pstmtCust.setString(1, nom);
                    pstmtCust.setString(2, adresse);
                    pstmtCust.setString(3, idType);
                    
                    ResultSet rsCust = pstmtCust.executeQuery();
                    int generatedCustomerId = 0;
                    if (rsCust.next()) {
                        generatedCustomerId = rsCust.getInt("customer_id");
                    }

                    // --- ÉTAPE 2 : Insertion de la RÉSERVATION ---
                    String sqlRes = "INSERT INTO reservation (room_number, hotel_number, start_date, end_date, customer_id, statut) VALUES (?, ?, ?, ?, ?, 'EN ATTENTE')";
                    PreparedStatement pstmtRes = conn.prepareStatement(sqlRes);
                    pstmtRes.setString(1, room);
                    pstmtRes.setInt(2, hotelId); // Utilisation de hotelId converti
                    pstmtRes.setDate(3, Date.valueOf(startStr)); 
                    pstmtRes.setDate(4, Date.valueOf(endStr));   
                    pstmtRes.setInt(5, generatedCustomerId);
                    pstmtRes.executeUpdate();
                    
                    %>
                    <div class="success-msg">
                        <h2>✅ Réservation Confirmée !</h2>
                        <p>Merci <strong><%= nom %></strong>.</p>
                        <p>Chambre n°<strong><%= room %></strong> réservée avec succès.</p>
                        <br><a href="index.html" style="text-decoration:none; color:#007BFF; font-weight:bold;">← Retour à l'accueil</a>
                    </div>
                    <%
                }
            } catch (Exception e) {
                out.println("<div style='color:red;'><strong>Erreur :</strong> " + e.getMessage() + "</div>");
            } finally {
                if (conn != null) conn.close();
            }
        } else {
            %>
            <h2>Finaliser votre séjour</h2>
            <div class="info-hotel">
                Hôtel : <strong><%= hotelRaw %></strong><br>
                Chambre : <strong><%= room %></strong><br>
                Dates : <strong><%= startStr %></strong> au <strong><%= endStr %></strong>
            </div>
            
            <form action="reservation.jsp" method="POST">
                <!-- On renvoie hotelRaw pour que la traduction se refasse au submit -->
                <input type="hidden" name="hotel" value="<%= hotelRaw %>">
                <input type="hidden" name="room" value="<%= room %>">
                <input type="hidden" name="start" value="<%= startStr %>">
                <input type="hidden" name="end" value="<%= endStr %>">
                <input type="hidden" name="action" value="confirm">

                <label>Nom Complet :</label>
                <input type="text" name="nom" required placeholder="Ex: Jean Tremblay">

                <label>Adresse :</label>
                <input type="text" name="adresse" required placeholder="Ex: 456 rue Ottawa">

                <label>Pièce d'identité :</label>
                <select name="id_type">
                    <option value="NAS">NAS</option>
                    <option value="Passeport">Passeport</option>
                    <option value="Permis de conduire">Permis de conduire</option>
                </select>

                <button type="submit" class="btn-confirm">Confirmer la Réservation</button>
            </form>
            <%
        }
    %>
</div>
</body>
</html>