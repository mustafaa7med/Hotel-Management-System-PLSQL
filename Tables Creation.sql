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

SELECT * FROM hotel;
SELECT * FROM room;
SELECT * FROM guest;
SELECT * FROM event;
SELECT * FROM room_reservation;
SELECT * FROM event_in_hotel;
SELECT * FROM room_registry;	