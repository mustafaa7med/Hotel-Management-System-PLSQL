-- Creating Object Package
-- Package Specs
CREATE OR REPLACE PACKAGE create_object IS
PROCEDURE add_hotel(h_id number,
                                      h_name varchar2,
                                      h_address varchar2,
                                      h_phone varchar2
                                      );
                      
PROCEDURE add_room(r_id number,
                                     h_id number,
                                     r_price number,
                                     r_size varchar2,
                                     r_capacity number
                                     );
                               
PROCEDURE add_guest(g_id number,
                                      g_name varchar2,
                                      g_phone varchar2,
                                      g_email varchar2
                                      );
                               
PROCEDURE book_room(r_id number,
                                      g_id number,
                                      b_id number,
                                      b_invoice number
                                      );
                         
PROCEDURE add_event(e_id number,
                                      e_name varchar2
                                      );
                              
PROCEDURE cancel_room_reservation(r_id number,
                                                    g_id number,
                                                    b_id number
                                                    );
                                                
END;

-- Package Body
CREATE OR REPLACE PACKAGE BODY create_object IS
PROCEDURE add_hotel(h_id number,
                                      h_name varchar2,
                                      h_address varchar2,
                                      h_phone varchar2
                      ) IS

BEGIN

    INSERT INTO hotel VALUES(hotel_seq.nextval, h_name, h_address, h_phone);
    
END;

PROCEDURE add_room(r_id number,
                                     h_id number,
                                     r_price number,
                                     r_size varchar2,
                                     r_capacity number
                                     ) IS
unique_exception EXCEPTION;  
PRAGMA EXCEPTION_INIT(unique_exception, -00001);
                                            
BEGIN
    
    INSERT INTO room VALUES(room_seq.nextval, h_id, r_price, r_size, r_capacity);

    EXCEPTION
        WHEN unique_exception THEN
            dbms_output.put_line(' The room size has to be one of the following: small, medium, large');
    
END;

PROCEDURE add_guest(g_id number,
                                      g_name varchar2,
                                      g_phone varchar2,
                                      g_email varchar2
                                      ) IS
BEGIN
    
    INSERT INTO guest VALUES(guest_seq.nextval, g_name, g_phone, g_email);

END;

PROCEDURE book_room(r_id number,
                                      g_id number,
                                      b_id number,
                                      b_invoice number
                                      ) IS
                                                                                         
foreign_exception EXCEPTION;                  
PRAGMA EXCEPTION_INIT(foreign_exception, -02291);       
                                                
BEGIN

    INSERT INTO room_reservation VALUES(r_id, g_id, b_id, b_invoice);
    
    EXCEPTION
        WHEN no_data_found THEN
                    dbms_output.put_line(g_id || ' Is not a registered guest, Kindly registed the guest before booking a room');
           
        WHEN foreign_exception THEN
         dbms_output.put_line(' There is a foreign key constraint, Kindly consider the values');

END;

PROCEDURE add_event(e_id number,
                                      e_name varchar2
                                      ) IS
                                               

BEGIN

    INSERT INTO event VALUES(event_seq.nextval, e_name);
    
END;

PROCEDURE cancel_room_reservation(r_id number,
                                                    g_id number,
                                                    b_id number
                                                    ) IS
                                                                                       
                                                                     
BEGIN

    DELETE FROM room_reservation WHERE room_id = r_id AND guest_id = g_id AND booking_id = b_id;
    
END;
END;

-- Finding Object Package
-- Package Spec
CREATE OR REPLACE PACKAGE find_object IS

FUNCTION find_hotel(h_id number) RETURN varchar2;

FUNCTION find_room(r_id number) RETURN varchar2;

FUNCTION find_reservation(b_id number) RETURN varchar2;

FUNCTION find_event(e_id number) RETURN varchar2;

FUNCTION find_event_reservation(e_id number) RETURN varchar2;

END;

-- Package Body
CREATE OR REPLACE PACKAGE BODY find_object IS

FUNCTION find_hotel(h_id number) RETURN varchar2 IS

v_h_id hotel.hotel_id%type;
v_h_name hotel.hotel_name%type;
v_h_address hotel.hotel_address%type;
v_h_phone hotel.hotel_phone%type;
hotel_details varchar2(150);

BEGIN

    SELECT hotel_id,
           hotel_name,
           hotel_address,
           hotel_phone
    INTO v_h_id,
         v_h_name,
         v_h_address,
         v_h_phone
    FROM hotel
    WHERE hotel_id = h_id;
    
    hotel_details := 'Hotel name is  ' || v_h_name || ', The address is  ' || v_h_address || ' and the phone number is ' || v_h_phone;
    RETURN hotel_details;
    
END;

FUNCTION find_room(r_id number) RETURN varchar2 IS


v_room_id room.room_id%type;
v_hotel_id room.hotel_id%type;
v_room_size room.room_size%type;
v_room_capacity room.room_capacity%type;
room_details varchar2(150);

BEGIN

    SELECT room_id,
           hotel_id,
           room_size,
           room_capacity
    INTO v_room_id,
         v_hotel_id,
         v_room_size,
         v_room_capacity
    FROM room
    WHERE room_id = r_id;
    
    room_details := 'Room ID is  ' ||v_room_id || ' That is in hotel ID  ' || v_hotel_id || ' The room size is  ' || v_room_size || ' and the capacity is  ' || v_room_capacity;
    RETURN room_details;
    
END;

FUNCTION find_reservation(b_id number) RETURN varchar2 IS

v_room_id room_reservation.room_id%type;
v_guest_id room_reservation.guest_id%type;
v_booking_id room_reservation.booking_id%type;
v_booking_invoice room_reservation.booking_invoice%type;
reservation_details varchar2(150);

BEGIN

    SELECT room_id,
           guest_id,
           booking_id,
           booking_invoice
    INTO v_room_id,
         v_guest_id,
         v_booking_id,
         v_booking_invoice
    FROM room_reservation
    WHERE booking_id = b_id;
    
    reservation_details := 'Room ' || v_room_id || ' Is reserved for ' || v_guest_id || ' with a booking ID ' || v_booking_id || ' and a booking invoice of approx. ' || v_booking_invoice;
    RETURN reservation_details;
    
END;

FUNCTION find_event(e_id number) RETURN varchar2 IS


v_event_id event.event_id%type;
v_event_name event.event_name%type;
event_details VARCHAR2(150);

BEGIN

    SELECT event_id,
           event_name
    INTO v_event_id,
         v_event_name
    FROM event
    WHERE event_id = e_id;
    
    event_details := 'Event id ' || v_event_id || ' is  ' || v_event_name;
    RETURN event_details;

END;

FUNCTION find_event_reservation(e_id number) RETURN varchar2 IS

v_event_id event_in_hotel.event_id%type;
v_guest_id event_in_hotel.guest_id%type;
v_reserv_id event_in_hotel.reserv_id%type;
v_start_date event_in_hotel.start_date%type;
v_end_date event_in_hotel.end_date%type;
v_event_invoice event_in_hotel.event_invoice%type;
event_reservation_details varchar2(250);

BEGIN

    SELECT event_id,
           guest_id,
           reserv_id,
           start_date,
           end_date,
           event_invoice
    INTO    v_event_id,
            v_guest_id,
            v_reserv_id,
            v_start_date,
            v_end_date,
            v_event_invoice
    FROM event_in_hotel
    WHERE event_id = e_id;
    
    event_reservation_details := 'Event  ' || v_event_id || ' which is booked by guest ID ' || v_guest_id || ' with a reservation id ' || v_reserv_id || ' has started on ' || v_start_date ||
                                              ' and an end date of ' || v_end_date || ' and its invoice is ' || v_event_invoice;
    RETURN event_reservation_details;
    
END;
END;