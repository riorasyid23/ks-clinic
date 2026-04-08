import { format, addMinutes, parse } from 'date-fns';

export const calculateAvailableSlots = (
  startTime: string, 
  endTime: string, 
  duration: number, 
  existingBookings: any[]
) => {
  const availableSlots = [];
  let currentTime = parse(startTime, 'HH:mm', new Date());
  const end = parse(endTime, 'HH:mm', new Date());

  while (currentTime < end) {
    const timeString = format(currentTime, 'HH:mm');
    const isBooked = existingBookings.some(
      booking => format(new Date(booking.date), 'HH:mm') === timeString
    );

    if (!isBooked) {
      availableSlots.push(timeString);
    }
    currentTime = addMinutes(currentTime, duration);
  }
  return availableSlots;
};