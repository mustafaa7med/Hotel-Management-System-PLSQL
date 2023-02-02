# Hotel Management System Using PLSQL
### Creating a Hotel Management System from scratch that automates hotel operations in terms of:
- Adding a new hotel branch.
- Adding a new guest.
- Adding a new room.
- Booking a Room.
- Tracking a room reservation. (Available/Booked)
- Canceling a room reservation.
- Creating an event.
- Booking and Recommending hotel events.
- Validating Reservations.

### Features:  

*Click to fly to the selected feature*

- [Add Hotel](#add-hotel) **{procedure}** 
- [Add Room](#add-room) **{procedure}**
- [Add Guest](#add-guest) **{procedure}**
- [Book Room](#book-room) **{procedure}**
- [Add Event](#add-event) **{procedure}**
- [Cancel Room Reservation](#cancel-room-reservation) **{procedure}**
- [Find Hotel](#find-hotel) **{function}**
- [Find Room](#find-room) **{function}**
- [Find Room Reservation](#find-room-reservation) **{function}**
- [Find Event](#find-event) **{function}**
- [Find Event Reservation](#find-event-reservation) **{function}**
- [Room Registry Trigger](#room-registry-trigger) **{trigger}**
- [Cancel Room Registry Trigger](#cancel-room-registry-trigger) **{trigger}**
- [Creating Object Package](#creating-object-package) **{package}**
- [Finding Object Package](#finding-object-package) **{package}**

**Note:** More features could be added later on to the project


## 1- Database Design (ERD and Mapping)

### ERD

![ERD](https://user-images.githubusercontent.com/81536586/215492194-43b72473-b4ea-4d75-9f45-f50217bcecf1.jpg)

### MAPPING

![MAPPING](https://user-images.githubusercontent.com/81536586/215492379-2b2d5459-6a1f-4129-8998-b0204cb1f2da.jpg)

## 2- Creating Tables

```sql
-- Creating all tables
CREATE TABLE hotel(hotel_id number primary key,
                   hotel_name varchar2(25),
                   hotel_address varchar2(25),
                   hotel_phone varchar2(25)
                   );
                               

CREATE TABLE room(room_id number primary key,
                  hotel_id number,
                  room_price number,
                  room_size varchar2(25),
                  room_capacity number,
                  CONSTRAINT room_fk FOREIGN KEY(hotel_id)
                  REFERENCES hotel(hotel_id),
                  CONSTRAINT room_size_ck
                  CHECK (Room_Size in ('small' , 'medium' , 'large' ))
                  );
                               
        
CREATE TABLE guest(guest_id number primary key,
                   guest_name varchar2(25),
                   guest_phone varchar2(25),
                   guest_email varchar2(35)
                   );


CREATE TABLE room_reservation(room_id number,
                              guest_id number,
                              booking_id number,
                              booking_invoice number,
                              CONSTRAINT reserv_pk PRIMARY KEY(room_id,guest_id),
                              FOREIGN KEY(room_id) REFERENCES room(room_id),
                              FOREIGN KEY(guest_id) REFERENCES guest(guest_id)
                              );
                                                 
               
CREATE TABLE event(event_id number primary key,
                   event_name varchar2(25)
                   );
                                
          

CREATE TABLE event_in_hotel(event_id number,
                            guest_id number,
                            reserv_id number,
                            start_date date,
                            end_date date,
                            event_invoice number,
                            CONSTRAINT room_hotel_pk PRIMARY KEY(event_id,guest_id)
                            );



-- Creating a table that restores the availability of the room
CREATE TABLE room_registry(room_id number, 
                           hotel_id number,
                           registry_date date,
                           room_availability varchar2(25),
                           CONSTRAINT registry_pk PRIMARY KEY(room_id, registry_date),
                           CHECK (Room_Availability in ('available' , 'booked' ))
                           );
```
# 3- Creating Sequences and Features for

- **Adding** hotels, rooms, guests, events.

- **Booking** rooms and events.

# Add Hotel 

```sql
-- Creating Sequence for Hotel_id
CREATE SEQUENCE hotel_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999 ORDER;

-- Creating a procedure to add new hotels
CREATE OR REPLACE PROCEDURE add_hotel(h_id number,
                                      h_name varchar2,
                                      h_address varchar2,
                                      h_phone varchar2
				      ) IS

BEGIN

    INSERT INTO hotel VALUES(hotel_seq.nextval, h_name, h_address, h_phone);
    
END;
```

# Add Room

```sql
-- Creating Sequence for room_id
CREATE SEQUENCE room_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999 ORDER;

-- Creating a procedure to add a new ROOM
CREATE OR REPLACE PROCEDURE add_room(r_id number,
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
```

# Add Guest

```sql
-- Creating Sequence for guest_id
CREATE SEQUENCE guest_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999 ORDER;

-- Creating a procedure to add a new GUEST
CREATE OR REPLACE PROCEDURE add_guest(g_id number,
                                      g_name varchar2,
                                      g_phone varchar2,
                                      g_email varchar2
                                      ) IS
BEGIN
    
    INSERT INTO guest VALUES(guest_seq.nextval, g_name, g_phone, g_email);

END;
```

# Book Room

```sql
-- Creating Sequence for booking_id
CREATE SEQUENCE book_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999 ORDER;


-- Creating a procedure to book a reservation
CREATE OR REPLACE PROCEDURE book_room(r_id number,
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
```
# Add Event

```sql
-- Creating Sequence for event_id
CREATE SEQUENCE event_seq START WITH 1 INCREMENT BY 1 MAXVALUE 999999 ORDER;


-- Creating a procedure to add a new event
CREATE OR REPLACE PROCEDURE add_event(e_id number,
                                      e_name varchar2
                                      ) IS
                                               

BEGIN

    INSERT INTO event VALUES(event_seq.nextval, e_name);
    
END;
```
# Cancel Room Reservation

```sql
-- Cancelling a room reservation
CREATE OR REPLACE PROCEDURE cancel_room_reservation(r_id number,
                                                    g_id number,
                                                    b_id number
                                                    ) IS
                                                                                       
                                                                     
BEGIN

    DELETE FROM room_reservation WHERE room_id = r_id AND guest_id = g_id AND booking_id = b_id;
    
END;
```

# 4- Creating Features For

- **Retrieving** hotel, room, guest, room and event details.

# Find Hotel

```sql
-- Creating a function to retrieve a hotel
CREATE OR REPLACE FUNCTION find_hotel(h_id number) RETURN varchar2 IS

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
```
# Find Room

```sql
-- Creating a function to retrieve room details
CREATE OR REPLACE FUNCTION find_room(r_id number) RETURN varchar2 IS


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
```

# Find Room Reservation

```sql
-- Creating a function to retrieve room_reservation details
CREATE OR REPLACE FUNCTION find_reservation(b_id number) RETURN varchar2 IS

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
```
# Find Event

```sql
-- Creating a function to retrieve event details
CREATE OR REPLACE FUNCTION find_event(e_id number) RETURN varchar2 IS


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
```
# Find Event Reservation

```sql
-- Creating a function to retrieve event reservation details
CREATE OR REPLACE FUNCTION find_event_reservation(e_id number) RETURN varchar2 IS

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
```

# Room Registry Trigger

```sql
-- Creating a trigger to track room's availability in case a room was reserved
CREATE OR REPLACE TRIGGER room_registry_trg
AFTER INSERT ON room_reservation
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW

BEGIN
    
    INSERT INTO room_registry VALUES(:Old.room_id, :Old.hotel_id, sysdate, 'booked');
    
END;
```

# Cancel Room Registry Trigger

```sql
-- Creating a trigger to track room's availablility in case a room was cancelled

CREATE OR REPLACE TRIGGER cancel_room_registry_trg
AFTER DELETE ON room_reservation
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW

BEGIN
    
    INSERT INTO room_registry VALUES(:Old.room_id, :Old.hotel_id, sysdate, 'available');
    
END;
```

# Creating Object Package

```sql
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
```

# Finding Object Package

```sql
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
```


## 🔗 Get In Touch
[![Email](https://img.shields.io/badge/Email_Me-000?style=for-the-badge&logo=ko-fi&logoColor=white)](mailto:mustafaa7med@gmail.com)

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mustafaa7med)
