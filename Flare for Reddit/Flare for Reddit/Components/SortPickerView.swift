import SwiftUI

struct SortPickerView: View {
    @Binding var selectedSort: SortType
    @Binding var selectedTime: TimeFilter
    let showTimeFilter: Bool

    init(selectedSort: Binding<SortType>, selectedTime: Binding<TimeFilter> = .constant(.day), showTimeFilter: Bool = false) {
        self._selectedSort = selectedSort
        self._selectedTime = selectedTime
        self.showTimeFilter = showTimeFilter
    }

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SortType.allCases, id: \.self) { sort in
                        sortButton(sort)
                    }
                }
                .padding(.horizontal, 16)
            }

            if showTimeFilter && (selectedSort == .top || selectedSort == .controversial) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TimeFilter.allCases, id: \.self) { time in
                            timeButton(time)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private func sortButton(_ sort: SortType) -> some View {
        Button(action: { selectedSort = sort }) {
            HStack(spacing: 4) {
                Image(systemName: sort.iconName)
                    .font(.system(size: 11))
                Text(sort.displayName)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selectedSort == sort ? Color.adaptivePrimary : Color.adaptiveSurface)
            .foregroundColor(selectedSort == sort ? .white : .adaptiveText2)
            .clipShape(Capsule())
        }
    }

    private func timeButton(_ time: TimeFilter) -> some View {
        Button(action: { selectedTime = time }) {
            Text(time.displayName)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(selectedTime == time ? Color.adaptivePrimary.opacity(0.15) : Color.adaptiveSurface)
                .foregroundColor(selectedTime == time ? .adaptivePrimary : .adaptiveText2)
                .clipShape(Capsule())
        }
    }
}
