import { CourseDetail } from '../course/CourseDetail'
import { AddBooking } from '../book/AddBooking'
import { BookingDetail } from '../book/BookingDetail'
import { BookingRecord } from '../book/BookingRecord'
import { ConfirmBooking } from '../book/ConfirmBooking'
import { StoreSelectPage } from '../components/StoreSelect'
import { ShowAllCourse } from '../course/ShowAllCourse'
import { UserCourses } from '../course/UserCourses'

@Builder
export function UserCoursesBuilder() {
  UserCourses();
}

@Builder
export function CourseDetailBuilder() {
  CourseDetail();
}

@Builder
export function AddBookingBuilder() {
  AddBooking();
}

@Builder
export function BookingDetailBuilder() {
  BookingDetail();
}

@Builder
export function BookingRecordBuilder() {
  BookingRecord();
}

@Builder
export function ConfirmBookingBuilder() {
  ConfirmBooking();
}

@Builder
export function StoreSelectBuilder() {
  StoreSelectPage();
}

@Builder
export function ShowAllCourseBuilder() {
  ShowAllCourse();
}

