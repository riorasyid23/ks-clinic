import { format, addMinutes, parse } from 'date-fns';

export const calculateAvailableSlots = (
  startTime: string, 
  endTime: string, 
  duration: number, 
  existingBookings: any[]
) => {
  const availableSlots = [];
  const unavailableSlots = []
  let currentTime = parse(startTime, 'HH:mm', new Date());
  const end = parse(endTime, 'HH:mm', new Date());

  while (currentTime < end) {
    const timeString = format(currentTime, 'HH:mm');
    // console.log(timeString)
    const isBooked = existingBookings.some(
      booking => {
        // console.log("Compare", booking.startTime, 'HH:mm' + " - " + timeString)
        // console.log("is this booked?", format(new Date(booking.date), 'HH:mm') === timeString)
        return booking.startTime === timeString
      }
    );

    // console.log("IS BOOKED", isBooked)


    if (!isBooked) {
      availableSlots.push(timeString);
    }else{
        unavailableSlots.push(timeString)
    }
    currentTime = addMinutes(currentTime, duration);
  }
  return { availableSlots, unavailableSlots };
};